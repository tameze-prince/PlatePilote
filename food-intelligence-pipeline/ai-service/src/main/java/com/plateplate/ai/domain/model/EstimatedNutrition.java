package com.plateplate.ai.domain.model;

import java.util.Map;

public class EstimatedNutrition {
    private Double calories;
    private Double proteinGrams;
    private Double carbsGrams;
    private Double fatGrams;
    private Double fiberGrams;
    private Double sugarGrams;
    private Double sodiumGrams;
    private Integer servings;
    private Map<String, Double> perIngredientCalories;
    private Double confidenceScore;

    public EstimatedNutrition() {}

    public Double getCalories() { return calories; }
    public void setCalories(Double calories) { this.calories = calories; }
    public Double getProteinGrams() { return proteinGrams; }
    public void setProteinGrams(Double proteinGrams) { this.proteinGrams = proteinGrams; }
    public Double getCarbsGrams() { return carbsGrams; }
    public void setCarbsGrams(Double carbsGrams) { this.carbsGrams = carbsGrams; }
    public Double getFatGrams() { return fatGrams; }
    public void setFatGrams(Double fatGrams) { this.fatGrams = fatGrams; }
    public Double getFiberGrams() { return fiberGrams; }
    public void setFiberGrams(Double fiberGrams) { this.fiberGrams = fiberGrams; }
    public Double getSugarGrams() { return sugarGrams; }
    public void setSugarGrams(Double sugarGrams) { this.sugarGrams = sugarGrams; }
    public Double getSodiumGrams() { return sodiumGrams; }
    public void setSodiumGrams(Double sodiumGrams) { this.sodiumGrams = sodiumGrams; }
    public Integer getServings() { return servings; }
    public void setServings(Integer servings) { this.servings = servings; }
    public Map<String, Double> getPerIngredientCalories() { return perIngredientCalories; }
    public void setPerIngredientCalories(Map<String, Double> perIngredientCalories) { this.perIngredientCalories = perIngredientCalories; }
    public Double getConfidenceScore() { return confidenceScore; }
    public void setConfidenceScore(Double confidenceScore) { this.confidenceScore = confidenceScore; }
}
