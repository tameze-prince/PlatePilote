package com.platepilote.platepilote.common.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Instant;
import java.util.Arrays;
import java.util.Comparator;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicLong;

/**
 * Filtre de limitation de débit (rate limiting) pour protéger les endpoints sensibles.
 * <p>
 * Empêche les attaques par force brute et le spam sur les endpoints d'authentification
 * en limitant le nombre de requêtes par adresse IP sur une fenêtre glissante de 1 minute.
 * </p>
 *
 * <p>Endpoints protégés : {@code /api/v1/auth/**}</p>
 * <p>Limite par défaut : 100 requêtes/minute/IP</p>
 */
@Slf4j
@Component
public class RateLimitingFilter extends OncePerRequestFilter {

    /** Nombre maximum de requêtes autorisées par fenêtre de temps. */
    @Value("${app.rate-limit.max-requests:100}")
    private int maxRequests;

    /** Durée de la fenêtre en secondes. */
    @Value("${app.rate-limit.window-seconds:60}")
    private int windowSeconds;

    /** Exact remote addresses of reverse proxies allowed to supply forwarding headers. */
    @Value("${app.rate-limit.trusted-proxies:}")
    private String trustedProxies;

    /** Upper bound for tracked client addresses to protect memory under address churn. */
    @Value("${app.rate-limit.max-tracked-clients:10000}")
    private int maxTrackedClients;

    /** Cache thread-safe des compteurs par IP. */
    private final ConcurrentHashMap<String, RateBucket> buckets = new ConcurrentHashMap<>();
    private final AtomicLong requestCounter = new AtomicLong();

    /**
     * Intercepte chaque requête et applique le rate limiting sur les endpoints protégés.
     *
     * @param request     requête HTTP
     * @param response    réponse HTTP
     * @param filterChain chaîne de filtres
     */
    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {
        String path = request.getRequestURI();

        // Applique le rate limiting uniquement sur les endpoints d'auth
        if (!path.startsWith("/api/v1/auth/")) {
            filterChain.doFilter(request, response);
            return;
        }

        String clientIp = resolveClientIp(request);

        if (!allowRequest(clientIp)) {
            log.warn("Rate limit exceeded for IP: {} on path: {}", clientIp, path);
            sendTooManyRequestsResponse(response);
            return;
        }

        filterChain.doFilter(request, response);
    }

    /**
     * Vérifie si une requête est autorisée pour l'IP donnée.
     * Utilise un bucket à token avec une fenêtre glissante de 1 minute.
     *
     * @param clientIp adresse IP du client
     * @return true si la requête est autorisée, false sinon
     */
    private boolean allowRequest(String clientIp) {
        long now = Instant.now().getEpochSecond();
        if (requestCounter.incrementAndGet() % 256 == 0) {
            buckets.entrySet().removeIf(entry ->
                    now - entry.getValue().windowStart >= windowSeconds);
        }

        RateBucket bucket = buckets.get(clientIp);
        if (bucket == null) {
            // Serialize only first-time client admission. Existing clients keep
            // the concurrent fast path below and are not globally bottlenecked.
            synchronized (buckets) {
                bucket = buckets.get(clientIp);
                if (bucket == null) {
                    if (buckets.size() >= maxTrackedClients) {
                        buckets.entrySet().removeIf(entry ->
                                now - entry.getValue().windowStart >= windowSeconds);
                        if (buckets.size() >= maxTrackedClients) {
                            // Keep the map bounded without denying every new client.
                            Map.Entry<String, RateBucket> oldest = buckets.entrySet().stream()
                                    .min(Comparator.comparingLong(entry -> entry.getValue().windowStart))
                                    .orElse(null);
                            if (oldest != null) {
                                buckets.remove(oldest.getKey(), oldest.getValue());
                            }
                        }
                    }
                    bucket = new RateBucket(now, new AtomicInteger(1));
                    buckets.put(clientIp, bucket);
                }
            }
        } else {
            bucket = buckets.compute(clientIp, (key, current) -> {
                if (current == null || now - current.windowStart >= windowSeconds) {
                    return new RateBucket(now, new AtomicInteger(1));
                }
                current.count.incrementAndGet();
                return current;
            });
        }
        return bucket.count.get() <= maxRequests;
    }

    /**
     * Extrait l'adresse IP réelle du client, en tenant compte des proxies.
     *
     * @param request requête HTTP
     * @return adresse IP du client
     */
    private String resolveClientIp(HttpServletRequest request) {
        String remoteAddress = request.getRemoteAddr();
        if (!isTrustedProxy(remoteAddress)) {
            // Client-supplied forwarding headers are untrusted by default.
            return remoteAddress;
        }

        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isBlank()) {
            String[] addresses = xForwardedFor.split(",");
            // A trusted proxy appends the peer address; use the right-most value
            // so a client cannot spoof the left-most X-Forwarded-For entry.
            String forwardedClient = addresses[addresses.length - 1].trim();
            if (!forwardedClient.isEmpty()) {
                return forwardedClient;
            }
        }
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isBlank()) {
            return xRealIp.trim();
        }
        return remoteAddress;
    }

    private boolean isTrustedProxy(String remoteAddress) {
        if (trustedProxies == null || trustedProxies.isBlank() || remoteAddress == null) {
            return false;
        }
        return Arrays.stream(trustedProxies.split(","))
                .map(String::trim)
                .anyMatch(remoteAddress::equals);
    }

    /**
     * Envoie une réponse 429 Too Many Requests.
     *
     * @param response réponse HTTP
     */
    private void sendTooManyRequestsResponse(HttpServletResponse response) throws IOException {
        response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setHeader("Retry-After", String.valueOf(windowSeconds));
        response.getWriter().write(
                "{\"error\":\"Too Many Requests\",\"message\":\"Rate limit exceeded. Please try again later.\",\"retryAfter\":" + windowSeconds + "}"
        );
    }

    /**
     * Bucket de rate limiting par IP.
     */
    private static class RateBucket {
        final long windowStart;
        final AtomicInteger count;

        RateBucket(long windowStart, AtomicInteger count) {
            this.windowStart = windowStart;
            this.count = count;
        }
    }

    /**
     * Nettoie périodiquement les buckets expirés pour éviter les fuites mémoire.
     * Les buckets de plus de 2 minutes sans activité sont supprimés.
     */
    @Override
    protected boolean shouldNotFilter(@NonNull HttpServletRequest request) {
        // Ce filtre s'applique toujours — le filtering est fait dans doFilterInternal
        return false;
    }
}