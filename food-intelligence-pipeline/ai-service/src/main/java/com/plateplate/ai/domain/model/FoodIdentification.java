package com.plateplate.ai.domain.model;

import java.util.List;

public class FoodIdentification {
    private String foodName;
    private Double confidenceScore;
    private List<String> categories;
    private List<String> detectedIngredients;
    private String sourceImageUrl;

    public FoodIdentification() {}

    public FoodIdentification(String foodName, Double confidenceScore, List<String> categories) {
        this.foodName = foodName;
        this.confidenceScore = confidenceScore;
        this.categories = categories;
    }

    public String getFoodName() { return foodName; }
    public void setFoodName(String foodName) { this.foodName = foodName; }
    public Double getConfidenceScore() { return confidenceScore; }
    public void setConfidenceScore(Double confidenceScore) { this.confidenceScore = confidenceScore; }
    public List<String> getCategories() { return categories; }
    public void setCategories(List<String> categories) { this.categories = categories; }
    public List<String> getDetectedIngredients() { return detectedIngredients; }
    public void setDetectedIngredients(List<String> detectedIngredients) { this.detectedIngredients = detectedIngredients; }
    public String getSourceImageUrl() { return sourceImageUrl; }
    public void setSourceImageUrl(String sourceImageUrl) { this.sourceImageUrl = sourceImageUrl; }
}
