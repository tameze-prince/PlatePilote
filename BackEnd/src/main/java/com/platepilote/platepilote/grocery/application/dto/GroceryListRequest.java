package com.platepilote.platepilote.grocery.application.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * Requête pour créer une nouvelle liste de courses.
 * <p>
 * Contient uniquement le nom de la liste ; les articles sont ajoutés
 * ultérieurement via des requêtes séparées.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GroceryListRequest {

    /** Nom de la liste de courses (obligatoire). */
    @NotBlank(message = "List name is required")
    private String name;
}
