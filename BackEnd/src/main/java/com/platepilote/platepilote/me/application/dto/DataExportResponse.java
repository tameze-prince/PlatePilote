package com.platepilote.platepilote.me.application.dto;

import com.platepilote.platepilote.pantry.application.dto.PantryItemResponse;
import com.platepilote.platepilote.preferences.application.dto.UserPreferencesResponse;
import com.platepilote.platepilote.recipes.application.dto.RecipeResponse;
import com.platepilote.platepilote.userprofile.application.dto.UserProfileResponse;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DataExportResponse {
    private UUID userId;
    private String email;
    private String firstName;
    private String lastName;
    private Instant accountCreatedAt;
    private Instant exportedAt;
    private Boolean analyticsOptOut;
    private Boolean processingRestricted;
    private UserProfileResponse profile;
    private UserPreferencesResponse preferences;
    private List<MealPlanExportDto> mealPlans;
    private List<GroceryListExportDto> groceryLists;
    private List<PantryItemResponse> pantryItems;
    private List<RecipeResponse> recipeFavorites;
    private List<RecipeResponse> personalRecipes;
}
