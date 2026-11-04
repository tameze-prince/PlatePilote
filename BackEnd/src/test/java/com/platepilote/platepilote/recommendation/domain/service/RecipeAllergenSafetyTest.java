package com.platepilote.platepilote.recommendation.domain.service;

import com.platepilote.platepilote.recipes.domain.entity.Recipe;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class RecipeAllergenSafetyTest {

    @Test
    void unknownAllergenStatusIsNotTreatedAsSafeForAnAllergicUser() {
        Recipe recipe = Recipe.builder().containsSoy(null).build();

        assertThat(RecommendationEngine.matchesAllergenFlag(recipe, "soy")).isTrue();
    }

    @Test
    void explicitNegativeAllergenStatusCanPassTheFlagCheck() {
        Recipe recipe = Recipe.builder().containsSoy(false).build();

        assertThat(RecommendationEngine.matchesAllergenFlag(recipe, "soy")).isFalse();
    }

    @Test
    void incompleteAllergenMetadataProducesAnExplicitWarning() {
        Recipe recipe = Recipe.builder()
                .containsGluten(false)
                .containsLactose(false)
                .containsNuts(false)
                .containsSoy(null)
                .containsEggs(false)
                .containsFish(false)
                .containsShellfish(false)
                .verified(false)
                .build();

        assertThat(RecommendationEngine.buildWarnings(recipe))
                .anyMatch(warning -> warning.contains("Allergen information is incomplete"));
    }
}
