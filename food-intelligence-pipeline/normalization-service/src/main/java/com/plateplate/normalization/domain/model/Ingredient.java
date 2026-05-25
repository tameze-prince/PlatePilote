package com.plateplate.normalization.domain.model;

import jakarta.persistence.*;

@Entity
@Table(name = "ingredients")
public class Ingredient {

    @Id
    private String id;

    @Column(name = "canonical_name", unique = true)
    private String canonicalName;

    @Column(unique = true)
    private String slug;

    private String category;

    public Ingredient() {}

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getCanonicalName() { return canonicalName; }
    public void setCanonicalName(String canonicalName) { this.canonicalName = canonicalName; }
    public String getSlug() { return slug; }
    public void setSlug(String slug) { this.slug = slug; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
}
