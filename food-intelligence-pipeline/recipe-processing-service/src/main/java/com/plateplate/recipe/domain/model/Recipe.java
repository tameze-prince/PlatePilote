package com.plateplate.recipe.domain.model;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "recipes")
public class Recipe {

    @Id
    private String id;

    private String title;

    private String cuisine;

    @ElementCollection
    @CollectionTable(name = "recipe_ingredient_lines", joinColumns = @JoinColumn(name = "recipe_id"))
    @Column(name = "line")
    private List<String> ingredientLines = new ArrayList<>();

    @ElementCollection
    @CollectionTable(name = "recipe_step_lines", joinColumns = @JoinColumn(name = "recipe_id"))
    @Column(name = "step")
    private List<String> steps = new ArrayList<>();

    public Recipe() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getCuisine() { return cuisine; }
    public void setCuisine(String cuisine) { this.cuisine = cuisine; }
    public List<String> getIngredientLines() { return ingredientLines; }
    public void setIngredientLines(List<String> ingredientLines) { this.ingredientLines = ingredientLines; }
    public List<String> getSteps() { return steps; }
    public void setSteps(List<String> steps) { this.steps = steps; }
}
