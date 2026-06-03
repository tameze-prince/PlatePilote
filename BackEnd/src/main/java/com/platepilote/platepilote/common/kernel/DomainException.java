package com.platepilote.platepilote.common.kernel;

/**
 * Exception de base pour toutes les erreurs métier de l'application.
 * <p>
 * Toutes les exceptions personnalisées héritent de cette classe,
 * permettant au {@link com.platepilote.platepilote.common.exception.GlobalExceptionHandler}
 * de les intercepter et de les convertir en réponses HTTP appropriées.
 * </p>
 */
public abstract class DomainException extends RuntimeException {

    /**
     * Crée une exception de domaine avec un message.
     *
     * @param message description de l'erreur
     */
    protected DomainException(String message) {
        super(message);
    }

    /**
     * Crée une exception de domaine avec un message et une cause.
     *
     * @param message description de l'erreur
     * @param cause   cause de l'exception
     */
    protected DomainException(String message, Throwable cause) {
        super(message, cause);
    }
}
