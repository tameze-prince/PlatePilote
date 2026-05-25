package com.plateplate.ai.application.service;

import com.plateplate.ai.domain.model.FoodIdentification;

public interface FoodImageIdentifier {
    FoodIdentification identify(String imageUrl);
    FoodIdentification identify(byte[] imageBytes, String filename);
    boolean canHandle(String imageUrl);
}
