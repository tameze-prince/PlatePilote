package com.platepilote.platepilote.common.kernel;

/**
 * Exception levée lorsqu'une ressource demandée (utilisateur, recette, etc.) n'existe pas.
 * <p>
 * Convertie en réponse HTTP 404 par {@link com.platepilote.platepilote.common.exception.GlobalExceptionHandler}.
 * </p>
 *
 * <p>Exemple : {@code new ResourceNotFoundException("User", "email", "john@email.com")}
 * produit le message {@code "User not found with email: 'john@email.com'"}.</p>
 */
public class ResourceNotFoundException extends DomainException {

    /**
     * Crée une exception avec un message formaté : "{ressource} introuvable avec {champ} : '{valeur}'".
     *
     * @param resourceName nom de la ressource (ex : "User")
     * @param fieldName    nom du champ de recherche (ex : "email")
     * @param fieldValue   valeur recherchée
     */
    public ResourceNotFoundException(String resourceName, String fieldName, Object fieldValue) {
        super(String.format("%s not found with %s: '%s'", resourceName, fieldName, fieldValue));
    }

    /**
     * Crée une exception avec un message personnalisé.
     *
     * @param message description de l'erreur
     */
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
