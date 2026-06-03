package com.platepilote.platepilote.common.exception;

/**
 * Gestionnaire global des exceptions pour tous les contrôleurs REST.
 * <p>
 * Intercepte les exceptions levées par les contrôleurs et les convertit
 * en réponses HTTP JSON standardisées.
 * </p>
 *
 * <p><b>Correspondance des exceptions :</b></p>
 * <ul>
 *   <li>{@code ResourceNotFoundException} → HTTP 404</li>
 *   <li>{@code BusinessRuleViolationException} → HTTP 422</li>
 *   <li>{@code DomainException} → HTTP 400</li>
 *   <li>{@code MethodArgumentNotValidException} → HTTP 400 (erreurs par champ)</li>
 *   <li>{@code BadCredentialsException} → HTTP 401</li>
 *   <li>{@code AccessDeniedException} → HTTP 403</li>
 *   <li>{@code Exception} (autres) → HTTP 500</li>
 * </ul>
 */
import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.kernel.DomainException;
import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.core.env.Environment;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
@RequiredArgsConstructor
public class GlobalExceptionHandler {

    private final Environment environment;

    /**
     * Gère les exceptions {@link ResourceNotFoundException} → HTTP 404.
     *
     * @param ex exception de ressource introuvable
     * @return réponse HTTP 404 avec les détails de l'erreur
     */
    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFound(ResourceNotFoundException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.NOT_FOUND.value(),
                ex.getMessage(),
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
    }

    /**
     * Gère les violations de règles métier {@link BusinessRuleViolationException} → HTTP 422.
     *
     * @param ex exception de violation de règle métier
     * @return réponse HTTP 422 avec les détails de l'erreur
     */
    @ExceptionHandler(BusinessRuleViolationException.class)
    public ResponseEntity<ErrorResponse> handleBusinessRuleViolation(BusinessRuleViolationException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.UNPROCESSABLE_ENTITY.value(),
                ex.getMessage(),
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.UNPROCESSABLE_ENTITY).body(error);
    }

    /**
     * Gère les exceptions du domaine {@link DomainException} → HTTP 400.
     *
     * @param ex exception du domaine
     * @return réponse HTTP 400 avec les détails de l'erreur
     */
    @ExceptionHandler(DomainException.class)
    public ResponseEntity<ErrorResponse> handleDomainException(DomainException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                ex.getMessage(),
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
    }

    /**
     * Gère les erreurs de validation des paramètres ({@link MethodArgumentNotValidException}) → HTTP 400.
     * <p>
     * Retourne les erreurs spécifiques à chaque champ pour affichage côté client.
     * </p>
     *
     * @param ex exception de validation des arguments
     * @return réponse HTTP 400 avec les erreurs par champ
     */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ValidationErrorResponse> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach(error -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        ValidationErrorResponse response = new ValidationErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                "Validation failed",
                Instant.now(),
                errors
        );
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
    }

    /**
     * Gère les échecs d'authentification {@link BadCredentialsException} → HTTP 401.
     *
     * @param ex exception de mauvaises identifiants
     * @return réponse HTTP 401
     */
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<ErrorResponse> handleBadCredentials(BadCredentialsException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.UNAUTHORIZED.value(),
                "Invalid credentials",
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
    }

    /**
     * Gère les refus d'accès {@link AccessDeniedException} → HTTP 403.
     *
     * @param ex exception d'accès refusé
     * @return réponse HTTP 403
     */
    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ErrorResponse> handleAccessDenied(AccessDeniedException ex) {
        ErrorResponse error = new ErrorResponse(
                HttpStatus.FORBIDDEN.value(),
                "Access denied",
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
    }

    /**
     * Gère toutes les exceptions non anticipées → HTTP 500.
     * <p>
     * En production, le message d'erreur est générique pour ne pas exposer de détails internes.
     * </p>
     *
     * @param ex exception générique
     * @return réponse HTTP 500
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        ex.printStackTrace();
        boolean production = Arrays.asList(environment.getActiveProfiles()).contains("prod");
        ErrorResponse error = new ErrorResponse(
                HttpStatus.INTERNAL_SERVER_ERROR.value(),
                production
                        ? "An unexpected error occurred"
                        : "An unexpected error occurred: " + ex.getClass().getSimpleName() + " - " + ex.getMessage(),
                Instant.now()
        );
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
    }

    /**
     * Format standard de réponse d'erreur retourné pour toutes les exceptions.
     */
    @Getter
    @AllArgsConstructor
    public static class ErrorResponse {
        /** Code HTTP d'erreur (404, 500, etc.). */
        private final int status;
        /** Message d'erreur lisible. */
        private final String message;
        /** Horodatage de l'erreur. */
        private final Instant timestamp;
    }

    /**
     * Réponse d'erreur étendue pour les erreurs de validation avec messages par champ.
     */
    @Getter
    public static class ValidationErrorResponse extends ErrorResponse {
        /** Carte des erreurs : nom du champ → message d'erreur. */
        private final Map<String, String> errors;

        public ValidationErrorResponse(int status, String message, Instant timestamp, Map<String, String> errors) {
            super(status, message, timestamp);
            this.errors = errors;
        }
    }
}
