package com.platepilote.platepilote.me.application.dto;

import com.platepilote.platepilote.pantry.application.dto.PantryItemResponse;
import com.platepilote.platepilote.recipes.application.dto.RecipeResponse;
import com.platepilote.platepilote.userprofile.application.dto.UserProfileResponse;
import com.platepilote.platepilote.preferences.application.dto.UserPreferencesResponse;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

/**
 * Réponse de l'endpoint {@code GET /api/v1/me/data-export}.
 * <p>
 * Conformité RGPD : droit d'accès (art. 15) + droit à la portabilité (art. 20).
 * Agrège l'ensemble des données personnelles détenues pour l'utilisateur courant,
 * dans un format portable (JSON) directement consommable par le mobile ou le web.
 * </p>
 *
 * <p><strong>Pourquoi des DTOs internes pour les sections meal-plan, grocery-list
 * et recipe-favorite ?</strong> Les modules {@code mealplanning} et {@code grocery}
 * n'exposent pas de {@code MealPlanResponse}/{@code GroceryListResponse}
 * stables ; pour éviter de coupler le DSAR à des API publiques mouvantes, le
 * module {@code me} embarque ses propres DTOs d'export ({@link MealPlanExportDto},
 * {@link GroceryListExportDto}). Une migration vers les DTOs publics pourra
 * avoir lieu plus tard si la stabilité est garantie.</p>
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DataExportResponse {

    /** Identifiant de l'utilisateur exporté. */
    private UUID userId;

    /** Email de l'utilisateur. */
    private String email;

    /** Prénom. */
    private String firstName;

    /** Nom de famille. */
    private String lastName;

    /** Date de création du compte (UTC). */
    private Instant accountCreatedAt;

    /** Date de génération de l'export (UTC). */
    private Instant exportedAt;

    /** Profil utilisateur (informations physiques, objectifs, localisation). */
    private UserProfileResponse profile;

    /** Préférences alimentaires (régimes, allergies, cuisines). */
    private UserPreferencesResponse preferences;

    /** Plans de repas de l'utilisateur. */
    private List<MealPlanExportDto> mealPlans;

    /** Listes de courses associées. */
    private List<GroceryListExportDto> groceryLists;

    /** Articles du garde-manger. */
    private List<PantryItemResponse> pantryItems;

    /** Recettes favorites de l'utilisateur (snapshot des {@link RecipeFavorite}). */
    private List<RecipeResponse> recipeFavorites;

    /** Recettes personnelles créées par l'utilisateur. */
    private List<RecipeResponse> personalRecipes;
}
