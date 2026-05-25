package com.plateplate.ai.domain.model;

import java.util.List;

public class ParsedRecipe {
    private String title;
    private List<ParsedIngredientLine> ingredients;
    private List<String> steps;
    private String cuisine;
    private Integer prepTimeMinutes;
    private Integer cookTimeMinutes;
    private Integer servings;
    private Double confidenceScore;

    public ParsedRecipe() {}

    public ParsedRecipe(String title, List<ParsedIngredientLine> ingredients, List<String> steps) {
        this.title = title;
        this.ingredients = ingredients;
        this.steps = steps;
        this.confidenceScore = 1.0;
    }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public List<ParsedIngredientLine> getIngredients() { return ingredients; }
    public void setIngredients(List<ParsedIngredientLine> ingredients) { this.ingredients = ingredients; }
    public List<String> getSteps() { return steps; }
    public void setSteps(List<String> steps) { this.steps = steps; }
    public String getCuisine() { return cuisine; }
    public void setCuisine(String cuisine) { this.cuisine = cuisine; }
    public Integer getPrepTimeMinutes() { return prepTimeMinutes; }
    public void setPrepTimeMinutes(Integer prepTimeMinutes) { this.prepTimeMinutes = prepTimeMinutes; }
    public Integer getCookTimeMinutes() { return cookTimeMinutes; }
    public void setCookTimeMinutes(Integer cookTimeMinutes) { this.cookTimeMinutes = cookTimeMinutes; }
    public Integer getServings() { return servings; }
    public void setServings(Integer servings) { this.servings = servings; }
    public Double getConfidenceScore() { return confidenceScore; }
    public void setConfidenceScore(Double confidenceScore) { this.confidenceScore = confidenceScore; }
}
