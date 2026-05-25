package com.plateplate.nutrition.domain.model;

import jakarta.persistence.*;

@Entity
@Table(name = "nutrition_facts")
public class NutritionFact {

    @Id
    private String id;

    @Column(name = "ingredient_id", unique = true)
    private String ingredientId;

    @Column(name = "calories_per_100g")
    private Integer caloriesPer100g;

    @Column(name = "protein_grams")
    private Double proteinGrams;

    @Column(name = "carbs_grams")
    private Double carbsGrams;

    @Column(name = "fat_grams")
    private Double fatGrams;

    public NutritionFact() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getIngredientId() { return ingredientId; }
    public void setIngredientId(String ingredientId) { this.ingredientId = ingredientId; }
    public Integer getCaloriesPer100g() { return caloriesPer100g; }
    public void setCaloriesPer100g(Integer caloriesPer100g) { this.caloriesPer100g = caloriesPer100g; }
    public Double getProteinGrams() { return proteinGrams; }
    public void setProteinGrams(Double proteinGrams) { this.proteinGrams = proteinGrams; }
    public Double getCarbsGrams() { return carbsGrams; }
    public void setCarbsGrams(Double carbsGrams) { this.carbsGrams = carbsGrams; }
    public Double getFatGrams() { return fatGrams; }
    public void setFatGrams(Double fatGrams) { this.fatGrams = fatGrams; }
}
