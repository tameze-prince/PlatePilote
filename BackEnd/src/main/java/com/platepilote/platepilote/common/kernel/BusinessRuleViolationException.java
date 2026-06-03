package com.platepilote.platepilote.common.kernel;

/**
 * Exception levée lorsqu'une règle métier est violée.
 * <p>
 * Exemples : email déjà utilisé, stock insuffisant, planification dans le passé.
 * Convertie en réponse HTTP 422 par {@link com.platepilote.platepilote.common.exception.GlobalExceptionHandler}.
 * </p>
 */
public class BusinessRuleViolationException extends DomainException {

    /**
     * Crée une exception de violation de règle métier.
     *
     * @param message description de la violation
     */
    public BusinessRuleViolationException(String message) {
        super(message);
    }
}
