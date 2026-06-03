# RAPPORT D'AUDIT DE SÉCURITÉ — PlatePilote
**Date:** 2 juin 2026 | **Backend:** Spring Boot 3.2.5 / Java 21 | **Frontend:** Flutter 3.11+

---

## 1. ÉTAT DE SANTÉ GLOBAL

| Composant | Status | Tests |
|-----------|--------|-------|
| Backend | ⚠️ Fonctionnel mais 11 vulnérabilités | 27/27 ✅ |
| Frontend | ⚠️ Fonctionnel mais 7 vulnérabilités | 17/17 ✅ |

**Serveur backend actif sur port 8080 ✅ BUILD SUCCESS**

---

## 2. VULNERABILITÉS CRITIQUES — À CORRIGER AVANT MISE EN PROD

### 🔴 C1 — JWT SECRET PLACEHOLDER EN PRODUCTION
**Risque:** Accès administrateur forcé  
**Backend:** `application.yml:146`

```yaml
secret: ${JWT_SECRET:Y2hhbmdlLXRoaXMtdG8tYS1sb25nLXNlY3VyZS1rZXktaW4tcHJvZHVjdGlvbi1lbnZpcm9ubWVudC1wbGVhc2U=}
```

Le secret par défaut (`change-this-to-a-long-secure-key-in-production-please`) est publique. Sans `JWT_SECRET` en env, **n'importe qui peut forger des JWT** et devenir SUPER_ADMIN.

**Solution — Ajouter une validation au démarrage dans `JwtService.java`:**

```java
@PostConstruct
public void validateSecret() {
    if (secretKey == null || secretKey.startsWith("change-this")) {
        throw new IllegalStateException(
            "JWT_SECRET must be set to a secure random value (min 256 bits)!");
    }
}
```

Commande pour générer: `openssl rand -base64 32`

---

### 🔴 C2 — STRIPE WEBHOOK: SIGNATURE NON VÉRIFIÉE SI HEADER ABSENT
**Risque:** Spoofing dewebhooks billing  
**Backend:** `BillingController.java:46`

```java
@RequestHeader(name = "Stripe-Signature", required = false) String signatureHeader
//                                                           ^^^^^^^^^^^^^ required=false !!!
```

Un attaquant peut envoyer des payloads falsifiés **sans aucune signature**.

**Solution:**

```java
@PostMapping("/webhook")
public ResponseEntity<ApiResponse<Void>> webhook(
        @RequestBody String rawPayload,
        @RequestHeader("Stripe-Signature") String signatureHeader) {
    // required=true (default) — throw 400 si absent
    billingService.processStripeWebhook(rawPayload, signatureHeader);
```

---

### 🔴 C3 — ÉNUMÉRATION D'EMAIL SUR `/resend-verification`
**Risque:** Discovery de comptes utilisateurs  
**Backend:** `EmailVerificationService.java:61-64`

```java
public void resendVerificationEmail(String email) {
    OurUser user = userRepository.findByEmail(email)
        .orElseThrow(() -> new ResourceNotFoundException("User", "email", email));
    //                          ^^^^^^^^^^^^^^^^^^^^^ RÉVÈLE que l'email existe
}
```

**Solution — Appliquer le pattern de `forgotPassword` (déjà bien implémenté):**

```java
public void resendVerificationEmail(String email) {
    userRepository.findByEmail(email)
        .ifPresent(user -> sendVerificationEmail(user));
    // Toujours retourner OK, ne jamais révéler l'existence
}
```

---

### 🔴 C4 — AUCUN RATE LIMITING SUR LES ENDPOINTS AUTH
**Risque:** Brute force / Credential stuffing  
**Backend:** Partout dans `AuthController`, `AuthService`

Les endpoints `/register`, `/login`, `/oauth2`, `/refresh` sont sans limite. Un attaquant peut tester des milliers de mots de passe.

**Solution — Bucket4j avec Redis:**

```java
// common/config/RateLimitingConfig.java
@Configuration
public class RateLimitingConfig {
    @Bean
    public FilterRegistrationBean<RateLimitingFilter> rateLimiter() {
        var bean = new FilterRegistrationBean<RateLimitingFilter>();
        bean.addUrlPatterns("/api/v1/auth/*");
        bean.setFilter(new RateLimitingFilter(
            Map.of(
                "/login"         , Bucket.builder().addLimit(5, Duration.ofMinutes(1)).build(),
                "/register"      , Bucket.builder().addLimit(3, Duration.ofMinutes(1)).build(),
                "/refresh"       , Bucket.builder().addLimit(10, Duration.ofMinutes(1)).build(),
                "/oauth2"        , Bucket.builder().addLimit(5, Duration.ofMinutes(1)).build(),
                "/resend-verification", Bucket.builder().addLimit(3, Duration.ofMinutes(1)).build()
            )
        ));
        return bean;
    }
}
```

```java
public class RateLimitingFilter extends OncePerRequestFilter {
    private final Map<String, Bucket> buckets;
    
    @Override
    protected void doFilterInternal(HttpServletRequest req, ...) {
        Bucket bucket = buckets.get(req.getRequestURI());
        if (bucket != null && bucket.tryConsume(1)) {
            chain.doFilter(req, res);  // OK
        } else {
            res.setStatus(429);
            res.getWriter().write("{\"error\":\"Too many requests\"}");
        }
    }
}
```

---

### 🔴 C5 — SSRF SUR `/identify-food`
**Risque:** Accès aux métadonnées cloud, ports internes  
**Backend:** `AiProxyController.java:27-31`

```java
@PostMapping("/identify-food")
public ResponseEntity<?> identifyFood(@RequestBody Map<String, String> body) {
    return aiServiceClient.identifyFood(body.getOrDefault("imageUrl", ""));
    //                                        ^^^^^^^^^^^^^^^^ AUCUNE VALIDATION
}
```

**Solution — Validation stricte dans `AiServiceClient.java`:**

```java
private static final Set<String> ALLOWED_SCHEMES = Set.of("http", "https");

private void validateImageUrl(String url) {
    if (url == null || url.isBlank()) throw new IllegalArgumentException("imageUrl required");
    URL parsed;
    try { parsed = new URL(url); } catch (MalformedURLException e) { throw new IllegalArgumentException("Invalid URL"); }
    if (!ALLOWED_SCHEMES.contains(parsed.getProtocol().toLowerCase()))
        throw new IllegalArgumentException("Only http/https allowed");
    String host = parsed.getHost().toLowerCase();
    if (host.equals("localhost") || host.equals("127.0.0.1") || 
        host.equals("0.0.0.0") || host.endsWith(".localhost") ||
        host.matches("^10\\..*") || host.matches("^172\\.(1[6-9]|2[0-9]|3[0-1])\\..*") ||
        host.matches("^192\\.168\\..*") || host.matches("^169\\.254\\..*") ||
        host.equals("metadata.google.internal") || host.contains("metadata.aws"))
        throw new IllegalArgumentException("Private/loopback URLs not allowed");
}

public Optional<Map<String, Object>> identifyFood(String imageUrl) {
    validateImageUrl(imageUrl);  // ← AJOUTER ICI
    var response = restTemplate.exchange(...);
```

---

## 3. VULNERABILITÉS HIGH

### 🟠 H1 — BUG SQL: RECIPES PUBLICS ACCESSIBLES COMME PRIVÉS
**Risque:** Fuite de recettes privées  
**Backend:** `RecipeRepository.java:76-78`

```java
@Query("... r.isPublic = true AND r.deletedAt IS NULL AND " +
       "LOWER(r.name) LIKE ... OR " +
       "LOWER(r.description) LIKE ...")
```

**Manque de parenthèses** — `isPublic=true AND deletedAt IS NULL` ne s'applique qu'au premier LIKE. Un recipe `isPublic=false` avec `description` correspondant au query serait retourné.

**Solution:**

```java
@Query("SELECT r FROM Recipe r WHERE r.isPublic = true AND r.deletedAt IS NULL AND " +
       "(LOWER(r.name) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
       "LOWER(r.description) LIKE LOWER(CONCAT('%', :query, '%')))")
Page<Recipe> searchPublicRecipes(@Param("query") String query, Pageable pageable);
```

---

### 🟠 H2 — PASSWORD SANS POLITIQUE DE COMPLEXITÉ
**Risque:** Comptes faciles à brute-forcer  
**Backend:** `RegisterRequest.java:52-54`

```java
@NotBlank @Size(min = 8)  // "aaaaaaaa" passe !
private String password;
```

**Solution — Ajouter Pattern + service de validation:**

```java
@NotBlank @Size(min = 8)
@Pattern(regexp = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=]).{8,}$",
         message = "Must contain uppercase, lowercase, digit, special char")
private String password;
```

```java
// PasswordPolicyValidator.java — blacklist des mots de passe courants
private static final Set<String> COMMON_PASSWORDS = Set.of(
    "password", "12345678", "qwertyui", "admin123", ...
);
public static void validate(String password) {
    if (COMMON_PASSWORDS.contains(password.toLowerCase()))
        throw new IllegalArgumentException("Password is too common");
}
```

---

### 🟠 H3 — REFRESH TOKEN SANS ROTATION (REPLAY ATTACK)
**Risque:** Token volé réutilisable indefiniment  
**Backend:** `AuthService.java:196-237`

Le refresh token n'est **pas marqué `revoked=true`** après usage. Un attaquant avec le token peut l'utiliser jusqu'à expiration.

**Solution:**

```java
// Dans refreshToken() — APRÈS validation mais AVANT d'émettre le nouveau:
persistedToken.setRevoked(true);
refreshTokenRepository.save(persistedToken);  // Invalider l'ancien

String newAccessToken = jwtService.generateToken(roleClaims(user), userDetails);
String newRefreshToken = issueRefreshToken(user, userDetails);  // Nouveau
```

---

### 🟠 H4 — DEBUG LOGGING EN PRODUCTION
**Risque:** Exposition passwords, tokens, données sensibles  
**Backend:** `application.yml:200-204`

```yaml
logging:
  level:
    com.platepilote: DEBUG        # ⚠️ passwords dans les logs!
    org.springframework.security: DEBUG
    org.hibernate.SQL: DEBUG
```

**Solution — Profiles Spring séparés:**

```yaml
# application.yml (commun)
spring:
  config:
    activate:
      on-profile: prod

# application-prod.yml
logging:
  level:
    com.platepilote: INFO
    org.springframework.security: WARN
    org.hibernate.SQL: WARN
    org.hibernate.type.descriptor.sql.BasicBinder: WARN  # Cache les params SQL
```

Activer avec: `SPRING_PROFILES_ACTIVE=prod mvn spring-boot:run`

---

### 🟠 H5 — CORS TROP PERMISSIF
**Risque:** Vol de session via subdomain malicious  
**Backend:** `application.yml:169`

```yaml
allowed-origins: ${CORS_ALLOWED_ORIGINS:http://localhost:59043,http://localhost:8081,http://localhost:*}
```

`localhost:*` en production autorise tout port localhost. Si un service malveillant tourne sur un port localhost, il peut voler les tokens.

**Solution:**

```java
// SecurityConfig.java — profiles
String[] allowedOrigins = Arrays.asList(env.getActiveProfiles()).contains("prod")
    ? new String[] {"https://app.platepilote.com", "https://www.platepilote.com"}
    : new String[] {"http://localhost:*"};
configuration.setAllowedOrigins(java.util.List.of(allowedOrigins));
```

---

### 🟠 H6 — TOKEN EMAIL VERIFICATION PRÉDICTIBLE (UUID.randomUUID())
**Risque:** Deviner le token et vérifier un email ajourd'hui  
**Backend:** `EmailVerificationService.java:50`

`UUID.randomUUID()` n'est pas cryptographiquement sécurisé.

**Solution:**

```java
import java.security.SecureRandom;
import java.util.HexFormat;

private String generateSecureToken() {
    byte[] bytes = new byte[32];
    new SecureRandom().nextBytes(bytes);
    return HexFormat.of().formatHex(bytes);  // 64 hex chars = 256 bits
}
```

---

### 🟠 H7 — ACCOUNT LOCKOUT MANQUANT
**Risque:** Brute force illimité sur le login  
**Backend:** `AuthService.java` (login)

**Solution:** Ajouter champs `failedLoginAttempts` + `lockoutUntil` dans `OurUser`:

```java
// Dans AuthService.login() — après BadCredentialsException:
user.setFailedLoginAttempts(user.getFailedLoginAttempts() + 1);
if (user.getFailedLoginAttempts() >= 5) {
    user.setLockoutUntil(Instant.now().plusSeconds(900));  // 15 min
}
userRepository.save(user);

// Dans UserDetailsServiceImpl — refuser si lockout:
if (user.getLockoutUntil() != null && user.getLockoutUntil().isAfter(Instant.now())) {
    throw new DisabledException("Account temporarily locked");
}
```

---

### 🟠 H8 — OPENAPI / SWAGGER ACCESSIBLE EN PROD
**Risque:** Révéler tous les endpoints et schemas  
**Backend:** `SecurityConfig.java:73-75`

Swagger est dans `PUBLIC_ENDPOINTS`.

**Solution:**

```java
// Dans securityFilterChain():
var docEndpoints = new String[] {"/v3/api-docs/**", "/swagger-ui/**", "/swagger-ui.html"};
if (!Arrays.asList(env.getActiveProfiles()).contains("prod")) {
    auth.requestMatchers(docEndpoints).permitAll();
}  // En prod: pas d'accès à Swagger
```

---

### 🟠 H9 — WEBTOKENSTORAGE EN PLAINTEXT (WEB)
**Risque:** Vol de tokens via XSS  
**Frontend:** `secure_storage_service.dart:72-75`

```dart
class WebTokenStorage implements TokenStorage {
  // Stocke en SharedPreferences → plaintext dans localStorage/IndexedDB
  await _prefs.setString(_accessTokenKey, accessToken);  // ← exposé!
}
```

**Solution — Chiffrer avec Web Crypto API:**

```dart
class SecureWebTokenStorage implements TokenStorage {
  Future<String> _encrypt(String data) async {
    final key = await _getOrCreateKey();  // AES-GCM 256-bit
    final iv = web.Crypto.getRandomValues(web.Uint8List(12));
    final encrypted = await web.crypto.subtle.encrypt(
      web.AesGcmParams(key: key, iv: iv),
      web.Uint8ListList.fromList(utf8.encode(data)),
    );
    return base64Encode(iv) + '.' + base64Encode(encrypted);
  }
}
```

Pour la prod web: utiliser des **HttpOnly cookies** (gérés par le backend).

---

### 🟠 H10 — DONNÉES HEALTH EN PLAINTEXT
**Risque:** Exposition données santé utilisateur  
**Frontend:** `profile_provider.dart:150-156,241-244`

```dart
await prefs.setString(_key, json.encode(state.toJson()));  // dateOfBirth, weightKg, heightCm
```

**Solution:** Chiffrer avec `flutter_secure_storage` (pas SharedPreferences):

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _secure = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.FIRST_UNTHIS),
);
await _secure.write(key: _profileKey, value: json.encode(profile.toJson()));
```

---

### 🟠 H11 — CERTIFICATE PINNING ABSENT (Android)
**Risque:** Attaques MITM sur mobile  
**Frontend:** `AndroidManifest.xml`

**Solution — Créer `android/app/src/main/res/xml/network_security_config.xml`:**

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
  <domain-config cleartextTrafficPermitted="false">
    <domain includeSubdomains="true">api.platepilote.com</domain>
    <pin-set expiration="2027-01-01">
      <pin digest="SHA-256">YOUR_PRIMARY_CERT_PIN</pin>
      <pin digest="SHA-256">YOUR_BACKUP_CERT_PIN</pin>
    </pin-set>
  </domain-config>
</network-security-config>
```

```xml
<!-- AndroidManifest.xml -->
<application
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

---

### 🟠 H12 — URL API HARDCODÉE LOCALHOST
**Risque:** Fuites vers localhost en production  
**Frontend:** `api_client.dart:9-12`

```dart
defaultValue: 'http://localhost:8081/api/v1'  // ← fallback dangerous
```

**Solution:**

```dart
baseUrl: () {
    final env = String.fromEnvironment('PLATEPILOT_API_BASE_URL', defaultValue: '');
    if (env.isEmpty || env.contains('localhost')) {
        throw AssertionError('PLATEPILOT_API_BASE_URL must be a production URL');
    }
    return env;
}(),
```

---

### 🟠 H13 — REFRESH TOKEN EN QUERY PARAMETER
**Risque:** Exposition dans les logs serveur  
**Frontend:** `api_client.dart:88-92`

```dart
await _refreshDio.post('/auth/refresh',
    queryParameters: {'refreshToken': refreshToken},  // ← dans l'URL!
);
```

**Solution:**

```dart
await _refreshDio.post('/auth/refresh',
    data: {'refreshToken': refreshToken},  // body, pas query
);
```

---

## 4. VULNERABILITÉS MEDIUM

### 🟡 M1 — SecurityUtils.getCurrentUserId() EMAIL LEAK
**Backend:** `SecurityUtils.java:21`

```java
.orElseThrow(() -> new RuntimeException("User not found: " + email));
//                                        ^^^^^^^^^^^^^^^^^^^^ leak l'email
```

**Solution:** `.orElseThrow(() -> new ResourceNotFoundException("User", "id", "current"));`

---

### 🟡 M2 — VALIDATION MANQUANTE UserProfileRequest
**Risque:** Valeurs numériques impossibles (height = -500cm)  
**Backend:** `UserProfileService.java:45-56`

**Solution:** Ajouter `@Min/@Max` et `@Pattern` sur les champs du DTO.

---

### 🟡 M3 — PASSWORD RESET TOKEN SANS REVOCATION
**Risque:** Token intercepté = account takeover permanent  
**Backend:** `JwtService.java:163-170` — token non enregistré en DB.

**Solution:** Stocker un hash du token en DB au moment de l'envoi, marquer `used=true` après reset.

---

### 🟡 M4 — PRINT() EN PROD DANS api_client.dart
**Risque:** Fuites d'URLs et données dans les logs  
**Frontend:** `api_client.dart:125`

```dart
print('[API Error] ${err.requestOptions.uri} - ${err.message}');
```

**Solution:**

```dart
import 'package:flutter/foundation.dart' show kDebugMode;
if (kDebugMode) print('[API Error] ...');
```

---

### 🟡 M5 — SESSION AUTH STATE EN PLAINTEXT
**Risque:** État d'auth lisible et modifiable côté client  
**Frontend:** `app_session_provider.dart:30-31`

```dart
isAuthenticated: preferences.getBool(_isAuthenticatedKey) ?? false,
```

**Solution:** Lire uniquement depuis `FlutterSecureStorage` (tokens présents = authentifié).

---

### 🟡 M6 — LOGGING SQL COMMENTS EN PROD
**Risque:** Données applicatives dans les commentaires SQL  
**Backend:** `application.yml` — `use_sql_comments: true`

---

### 🟡 M7 — LOGIN ERROR MESSAGE DIFFÉRENCIÉE
**Risque:** Enumération d'emails valides  
**Backend:** `AuthService.java` — les messages d'erreur login peuvent différentier "user not found" de "bad password".

---

## 5. BONNES PRATIQUES CONSTATÉES ✅

| Élément | Fichier | Status |
|---------|---------|--------|
| BCrypt pour passwords | SecurityConfig | ✅ |
| Refresh token SHA-256 hashé | AuthService:215 | ✅ |
| Revocation refresh sur logout | AuthService:240 | ✅ |
| Anti-enumeration forgotPassword | AuthService:257 | ✅ |
| Stripe webhook signature verify | StripeBillingProvider:106 | ✅ |
| OAuth2 aud/iss validation | OidcIdentityVerifier:39-45 | ✅ |
| CSRF disabled (JWT stateless) | SecurityConfig:91 | ✅ |
| @Transactional sur mutations | Partout | ✅ |
| HTTPS via reverse proxy (à configurer) | — | ⚠️ à faire |

---

## 6. DÉPENDANCES À METTRE À JOUR

### Flutter (pub outdated)

| Package | Current | Latest | Risque |
|---------|---------|--------|--------|
| `google_sign_in` | 6.3.0 | 7.2.0 | Mise à jour recommandée |
| `go_router` | 16.3.0 | 17.2.3 | Mise à jour recommandée |
| `flutter_secure_storage` | 10.2.0 | 10.3.1 | Mineur |
| `image_picker_android` | 0.8.13+17 | 0.8.13+18 | Mineur |

```bash
flutter pub upgrade google_sign_in go_router flutter_secure_storage
```

### Java/Maven

```bash
cd BackEnd && mvn versions:display-dependency-updates
```

---

## 7. PLAN D'ACTION PAR ORDRE DE PRIORITÉ

### Phase 1 — IMMÉDIATE (avant premier déploiement)

1. [ ] **C1** — Définir `JWT_SECRET` env var en prod (min 256 bits)
2. [ ] **C2** — Fixer `required=false` sur Stripe-Signature header
3. [ ] **C3** — Uniformiser resend-verification (ne jamais révéler existence email)
4. [ ] **C4** — Implémenter rate limiting sur `/api/v1/auth/*`
5. [ ] **C5** — Validation URL image anti-SSRF dans AiServiceClient
6. [ ] **H1** — Corriger parenthèses manquantes dans RecipeRepository
7. [ ] **H4** — Activer profile prod (désactiver DEBUG logging)

### Phase 2 — COURTE (prochaine release)

8. [ ] **H2** — Politique de mot de passe + account lockout
9. [ ] **H3** — Rotation refresh tokens
10. [ ] **H6** — SecureRandom pour tokens email
11. [ ] **H7** — Account lockout après failed logins
12. [ ] **H8** — Désactiver Swagger en prod
13. [ ] **H11** — Certificate pinning Android
14. [ ] **H12** — Vérifier que PLATEPILOT_API_BASE_URL n'est pas localhost
15. [ ] **H13** — Refresh token en body, pas query param

### Phase 3 — MOYEN TERME

16. [ ] **H9** — Chiffrer tokens sur web (Web Crypto API)
17. [ ] **H10** — Chiffrer profile avec FlutterSecureStorage
18. [ ] **M1** — Corriger leak email dans SecurityUtils
19. [ ] **M2** — Validation UserProfileRequest
20. [ ] **M3** — Password reset token DB revocation
21. [ ] **M4** — Envelopper print() avec kDebugMode
22. [ ] **M5** — Session state depuis secure storage
23. [ ] **M6** — use_sql_comments: false en prod
24. [ ] Mettre à jour google_sign_in, go_router

---

## 8. CONFIGURATION PROD RECOMMANDÉE

```bash
# .env.production
SPRING_PROFILES_ACTIVE=prod
PLATEPILOT_API_BASE_URL=https://api.platepilote.com
JWT_SECRET=<openssl rand -base64 32>
DB_PASSWORD=<generated>
REDIS_PASSWORD=<generated>
BREVO_SMTP_KEY=<from Brevo dashboard>
GOOGLE_OAUTH_CLIENT_ID=<from Google Cloud>
APPLE_OAUTH_CLIENT_ID=<from Apple Developer>
FACEBOOK_OAUTH_CLIENT_ID=<from Meta>
STRIPE_WEBHOOK_SECRET=<from Stripe Dashboard>
CORS_ALLOWED_ORIGINS=https://app.platepilote.com,https://www.platepilote.com
```

```yaml
# application-prod.yml
spring:
  jpa:
    show-sql: false
    properties:
      hibernate:
        use_sql_comments: false
  h2:
    console:
      enabled: false  # Disable H2 console in prod
  actuator:
    endpoints:
      web:
        exposure:
          include: health,info
        base-path: /actuator
  security:
    enabled: true

logging:
  level:
    com.platepilote: INFO
    org.springframework.security: WARN
    org.hibernate.SQL: WARN

server:
  ssl:
    enabled: true  # Si TLS direct, sinon via reverse proxy (nginx)
```

---

*Rapport généré le 2 juin 2026 — Analyse statique complète du code source*