package com.plateplate.nutrition.domain.model;

import jakarta.persistence.*;

@Entity
@Table(name = "recipe_nutrition")
public class RecipeNutrition {

    @Id
    private String id;

    @Column(name = "recipe_id")
    private String recipeId;

    @Column(name = "calories_per_serving")
    private Integer caloriesPerServing;

    @Column(name = "protein_grams")
    private Double proteinGrams;

    @Column(name = "carbs_grams")
    private Double carbsGrams;

    @Column(name = "fat_grams")
    private Double fatGrams;

    private Integer servings;

    public RecipeNutrition() {}

    public RecipeNutrition(String id, String recipeId) {
        this.id = id;
        this.recipeId = recipeId;
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getRecipeId() { return recipeId; }
    public void setRecipeId(String recipeId) { this.recipeId = recipeId; }
    public Integer getCaloriesPerServing() { return caloriesPerServing; }
    public void setCaloriesPerServing(Integer caloriesPerServing) { this.caloriesPerServing = caloriesPerServing; }
    public Double getProteinGrams() { return proteinGrams; }
    public void setProteinGrams(Double proteinGrams) { this.proteinGrams = proteinGrams; }
    public Double getCarbsGrams() { return carbsGrams; }
    public void setCarbsGrams(Double carbsGrams) { this.carbsGrams = carbsGrams; }
    public Double getFatGrams() { return fatGrams; }
    public void setFatGrams(Double fatGrams) { this.fatGrams = fatGrams; }
    public Integer getServings() { return servings; }
    public void setServings(Integer servings) { this.servings = servings; }
}
