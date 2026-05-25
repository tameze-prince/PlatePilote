package com.plateplate.ai.application.service;

import com.plateplate.ai.domain.model.ParsedRecipe;

public interface RecipeTextParser {
    ParsedRecipe parse(String rawText);
    boolean canHandle(String rawText);
}
