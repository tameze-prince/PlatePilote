package com.plateplate.ai.application.service;

import com.plateplate.ai.domain.model.FoodIdentification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Map;
import java.util.Optional;

public class DefaultFoodImageIdentifier implements FoodImageIdentifier {
    private static final Logger log = LoggerFactory.getLogger(DefaultFoodImageIdentifier.class);
    private static final double FALLBACK_CONFIDENCE = 0.4;

    private static final Map<String, List<String>> KEYWORD_FOOD_MAP = Map.ofEntries(
        Map.entry("pizza", List.of("Pizza", "Italian", "Main Course")),
        Map.entry("pasta", List.of("Pasta", "Italian", "Main Course")),
        Map.entry("burger", List.of("Burger", "American", "Main Course")),
        Map.entry("salad", List.of("Salad", "Healthy", "Side Dish")),
        Map.entry("soup", List.of("Soup", "Comfort Food", "Appetizer")),
        Map.entry("cake", List.of("Cake", "Dessert", "Baked Goods")),
        Map.entry("cookie", List.of("Cookie", "Dessert", "Baked Goods")),
        Map.entry("bread", List.of("Bread", "Baked Goods", "Side Dish")),
        Map.entry("rice", List.of("Rice", "Asian", "Main Course")),
        Map.entry("fish", List.of("Fish", "Seafood", "Main Course")),
        Map.entry("chicken", List.of("Chicken", "Poultry", "Main Course")),
        Map.entry("steak", List.of("Steak", "Beef", "Main Course")),
        Map.entry("taco", List.of("Taco", "Mexican", "Main Course")),
        Map.entry("sushi", List.of("Sushi", "Japanese", "Main Course")),
        Map.entry("curry", List.of("Curry", "Indian", "Main Course")),
        Map.entry("omelet", List.of("Omelette", "Breakfast", "Main Course")),
        Map.entry("pancake", List.of("Pancake", "Breakfast", "Baked Goods")),
        Map.entry("smoothie", List.of("Smoothie", "Healthy", "Beverage")),
        Map.entry("sandwich", List.of("Sandwich", "American", "Main Course"))
    );

    @Override
    public FoodIdentification identify(String imageUrl) {
        log.info("Identifying food from image URL: {}", imageUrl);
        if (imageUrl == null || imageUrl.isBlank()) {
            return fallbackIdentification(null);
        }
        return identifyFromUrl(imageUrl);
    }

    @Override
    public FoodIdentification identify(byte[] imageBytes, String filename) {
        log.info("Identifying food from image bytes, filename: {}", filename);
        if (imageBytes == null || imageBytes.length == 0) {
            return fallbackIdentification(filename);
        }
        return identifyFromFilename(filename);
    }

    @Override
    public boolean canHandle(String imageUrl) {
        return imageUrl != null && !imageUrl.isBlank();
    }

    private FoodIdentification identifyFromUrl(String url) {
        String lowerUrl = url.toLowerCase();
        for (Map.Entry<String, List<String>> entry : KEYWORD_FOOD_MAP.entrySet()) {
            if (lowerUrl.contains(entry.getKey())) {
                List<String> info = entry.getValue();
                FoodIdentification id = new FoodIdentification(info.get(0), 0.7, info.subList(1, info.size()));
                id.setSourceImageUrl(url);
                return id;
            }
        }
        return fallbackIdentification(url);
    }

    private FoodIdentification identifyFromFilename(String filename) {
        if (filename == null) return fallbackIdentification(null);
        String lower = filename.toLowerCase();
        Optional<Map.Entry<String, List<String>>> match = KEYWORD_FOOD_MAP.entrySet().stream()
            .filter(e -> lower.contains(e.getKey()))
            .findFirst();
        if (match.isPresent()) {
            List<String> info = match.get().getValue();
            return new FoodIdentification(info.get(0), 0.65, info.subList(1, info.size()));
        }
        return fallbackIdentification(filename);
    }

    private FoodIdentification fallbackIdentification(String source) {
        FoodIdentification id = new FoodIdentification("Unknown Food", FALLBACK_CONFIDENCE, List.of("Uncategorized"));
        if (source != null) id.setSourceImageUrl(source);
        log.debug("Fallback identification used for: {}", source);
        return id;
    }
}
