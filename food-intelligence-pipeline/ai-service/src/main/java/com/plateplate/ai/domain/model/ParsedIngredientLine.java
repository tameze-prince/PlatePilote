package com.plateplate.ai.domain.model;

public class ParsedIngredientLine {
    private String raw;
    private Double quantity;
    private String unit;
    private String name;
    private String preparation;
    private Boolean verified;

    public ParsedIngredientLine() {}

    public ParsedIngredientLine(String raw, Double quantity, String unit, String name) {
        this.raw = raw;
        this.quantity = quantity;
        this.unit = unit;
        this.name = name;
        this.verified = false;
    }

    public String getRaw() { return raw; }
    public void setRaw(String raw) { this.raw = raw; }
    public Double getQuantity() { return quantity; }
    public void setQuantity(Double quantity) { this.quantity = quantity; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPreparation() { return preparation; }
    public void setPreparation(String preparation) { this.preparation = preparation; }
    public Boolean getVerified() { return verified; }
    public void setVerified(Boolean verified) { this.verified = verified; }
}
