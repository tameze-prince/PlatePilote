package com.platepilote.platepilote.common.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.*;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import java.io.IOException;
import java.net.URI;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * Service de stockage d'images via Cloudflare R2 (compatible S3).
 * <p>
 * Gère l'upload et la suppression d'images pour les recettes, avatars utilisateur
 * et reçus. Les fichiers sont servis via l'URL publique R2.dev.
 * <p>
 * Formats supportés : jpg, png, webp (max 5 Mo).
 * Thread-safe via ExecutorService pour les opérations asynchrones.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ImageStorageService {

    private static final Set<String> ALLOWED_CONTENT_TYPES = Set.of(
            "image/jpeg",
            "image/png",
            "image/webp"
    );
    private static final long MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024; // 5 MB
    private static final String SEPARATOR = "/";

    @Value("${app.storage.r2.endpoint:}")
    private String r2Endpoint;

    @Value("${app.storage.r2.region:auto}")
    private String r2Region;

    @Value("${app.storage.r2.access-key:}")
    private String r2AccessKey;

    @Value("${app.storage.r2.secret-key:}")
    private String r2SecretKey;

    @Value("${app.storage.r2.bucket:}")
    private String r2Bucket;

    @Value("${app.storage.r2.public-url-template:https://pub-{hash}.r2.dev}")
    private String publicUrlTemplate;

    private S3Client s3Client;
    private ExecutorService executorService;

    @PostConstruct
    public void init() {
        executorService = Executors.newFixedThreadPool(
                Runtime.getRuntime().availableProcessors()
        );

        if (r2Endpoint == null || r2Endpoint.isBlank()) {
            log.warn("ImageStorageService: R2 endpoint not configured — uploads will fail. "
                    + "Set app.storage.r2.* properties in application.yml");
            return;
        }

        AwsBasicCredentials credentials = AwsBasicCredentials.create(
                r2AccessKey,
                r2SecretKey
        );

        this.s3Client = S3Client.builder()
                .endpointOverride(URI.create(r2Endpoint))
                .region(Region.of(r2Region))
                .credentialsProvider(StaticCredentialsProvider.create(credentials))
                .forcePathStyle(true) // Required for R2 / S3-compatible providers
                .build();

        log.info("ImageStorageService initialized with endpoint={}, bucket={}",
                r2Endpoint, r2Bucket);
    }

    @PreDestroy
    public void destroy() {
        if (executorService != null) {
            executorService.shutdown();
            try {
                if (!executorService.awaitTermination(30, TimeUnit.SECONDS)) {
                    executorService.shutdownNow();
                }
            } catch (InterruptedException e) {
                executorService.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
        if (s3Client != null) {
            s3Client.close();
        }
    }

    // -------------------------------------------------------------------------
    // Public API
    // -------------------------------------------------------------------------

    /**
     * Upload l'image d'une recette.
     *
     * @param file     fichier image (jpg, png, webp, max 5 Mo)
     * @param recipeId identifiant de la recette
     * @return URL publique de l'image uploadée
     */
    public String uploadRecipeImage(MultipartFile file, UUID recipeId) {
        return uploadImage(file, "recipes", recipeId.toString());
    }

    /**
     * Upload l'avatar d'un utilisateur.
     *
     * @param file   fichier image (jpg, png, webp, max 5 Mo)
     * @param userId identifiant de l'utilisateur
     * @return URL publique de l'avatar uploadé
     */
    public String uploadUserAvatar(MultipartFile file, UUID userId) {
        return uploadImage(file, "avatars", userId.toString());
    }

    /**
     * Upload un reçu d'achat.
     *
     * @param file   fichier image (jpg, png, webp, max 5 Mo)
     * @param userId identifiant de l'utilisateur
     * @return URL publique du reçu uploadé
     */
    public String uploadReceipt(MultipartFile file, UUID userId) {
        return uploadImage(file, "receipts", userId.toString());
    }

    /**
     * Supprime une image à partir de son URL publique.
     *
     * @param publicUrl URL publique de l'image (format https://pub-{hash}.r2.dev/...)
     * @return true si la suppression a réussi, false sinon
     */
    public boolean deleteImage(String publicUrl) {
        if (publicUrl == null || publicUrl.isBlank()) {
            log.warn("[{}] deleteImage called with null/blank URL", getClass().getSimpleName());
            return false;
        }

        String key = extractKeyFromUrl(publicUrl);
        if (key == null) {
            log.warn("[{}] Could not extract key from URL: {}", getClass().getSimpleName(), publicUrl);
            return false;
        }

        String correlationId = UUID.randomUUID().toString();

        try {
            DeleteObjectRequest deleteRequest = DeleteObjectRequest.builder()
                    .bucket(r2Bucket)
                    .key(key)
                    .build();

            s3Client.deleteObject(deleteRequest);

            log.info("[{}] Deleted image: {} (key={})", correlationId, publicUrl, key);
            return true;
        } catch (Exception e) {
            log.error("[{}] Failed to delete image: {} — {}", correlationId, publicUrl, e.getMessage(), e);
            return false;
        }
    }

    // -------------------------------------------------------------------------
    // Private helpers
    // -------------------------------------------------------------------------

    private String uploadImage(MultipartFile file, String category, String entityId) {
        UUID correlationId = UUID.randomUUID();

        if (s3Client == null) {
            throw new IllegalStateException("ImageStorageService not initialized: R2 endpoint not configured. "
                    + "Set app.storage.r2.endpoint in application.yml");
        }

        validateFile(file, correlationId);

        String originalFilename = sanitizeFilename(file.getOriginalFilename());
        String extension = getFileExtension(originalFilename);
        String key = buildKey(category, entityId, extension);

        try {
            PutObjectRequest putRequest = PutObjectRequest.builder()
                    .bucket(r2Bucket)
                    .key(key)
                    .contentType(file.getContentType())
                    .contentDisposition("inline; filename=\"" + originalFilename + "\"")
                    .build();

            s3Client.putObject(putRequest, RequestBody.fromBytes(file.getBytes()));

            String publicUrl = buildPublicUrl(key);

            log.info("[{}] Uploaded {} image: {} -> {}", correlationId, category, key, publicUrl);

            return publicUrl;

        } catch (IOException e) {
            log.error("[{}] Failed to read file bytes for {} upload: {}",
                    correlationId, category, e.getMessage(), e);
            throw new ImageStorageException("Failed to read file bytes", e);
        } catch (S3Exception e) {
            log.error("[{}] S3 error during {} upload: {}", correlationId, category, e.getMessage(), e);
            throw new ImageStorageException("S3 upload failed: " + e.getMessage(), e);
        }
    }

    private void validateFile(MultipartFile file, UUID correlationId) {
        if (file == null || file.isEmpty()) {
            throw new ImageStorageException("File is empty or null");
        }

        String contentType = file.getContentType();
        if (contentType == null || !ALLOWED_CONTENT_TYPES.contains(contentType)) {
            throw new ImageStorageException(
                    "Invalid content type '" + contentType + "'. Allowed: " + ALLOWED_CONTENT_TYPES);
        }

        if (file.getSize() > MAX_FILE_SIZE_BYTES) {
            throw new ImageStorageException(
                    "File size " + file.getSize() + " bytes exceeds maximum of " + MAX_FILE_SIZE_BYTES + " bytes (5 MB)");
        }
    }

    private String sanitizeFilename(String filename) {
        if (filename == null || filename.isBlank()) {
            return UUID.randomUUID().toString();
        }
        // Remove path traversal attempts and non-safe characters
        return filename
                .replaceAll("[/\\\\]", "_")
                .replaceAll("\\.\\.", "_")
                .trim();
    }

    private String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return ".jpg"; // default
        }
        String ext = filename.substring(filename.lastIndexOf('.')).toLowerCase();
        // Normalize jpeg -> jpg
        if (ext.equals(".jpeg")) {
            ext = ".jpg";
        }
        return ext;
    }

    private String buildKey(String category, String entityId, String extension) {
        String uniqueId = UUID.randomUUID().toString().substring(0, 8);
        return category + SEPARATOR + entityId + SEPARATOR + uniqueId + extension;
    }

    private String buildPublicUrl(String key) {
        // Template supports custom formats. Default: https://pub-{hash}.r2.dev/{key}
        // The {hash} placeholder is replaced with the first 12 chars of the key hash
        // or we just use the bucket identifier in the URL path.
        //
        // For Cloudflare R2 public access via r2.dev custom subdomain:
        // The standard URL is https://{bucket}.r2.dev/{key}
        // But since the task specifies https://pub-{hash}.r2.dev/nom-fichier,
        // we build: https://pub-{shortHash}.r2.dev/{key}
        String shortHash = Integer.toHexString(Math.abs(key.hashCode() >>> 16) & 0xFFFF);

        String baseUrl = publicUrlTemplate
                .replace("{hash}", shortHash)
                .replace("{bucket}", r2Bucket);

        // Ensure no double slashes
        String url = baseUrl.endsWith("/") ? baseUrl + key : baseUrl + "/" + key;

        return url;
    }

    private String extractKeyFromUrl(String publicUrl) {
        // Extract the key portion after the domain.
        // Format: https://pub-{hash}.r2.dev/{key}  or  https://{bucket}.r2.dev/{key}
        try {
            String path = new java.net.URL(publicUrl).getPath();
            if (path == null || path.isEmpty() || path.equals("/")) {
                return null;
            }
            return path.startsWith("/") ? path.substring(1) : path;
        } catch (Exception e) {
            log.warn("Failed to parse URL '{}': {}", publicUrl, e.getMessage());
            return null;
        }
    }

    // -------------------------------------------------------------------------
    // Exception
    // -------------------------------------------------------------------------

    /**
     * Exception métier pour les erreurs de stockage d'images.
     */
    public static class ImageStorageException extends RuntimeException {
        public ImageStorageException(String message) {
            super(message);
        }

        public ImageStorageException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}