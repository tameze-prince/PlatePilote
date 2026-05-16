package com.platepilote.platepilote.pricing.domain.repository;

import com.platepilote.platepilote.pricing.domain.entity.IngredientPrice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface IngredientPriceRepository extends JpaRepository<IngredientPrice, UUID> {

    List<IngredientPrice> findByIngredientId(UUID ingredientId);

    Optional<IngredientPrice> findTopByIngredientIdAndCountryCodeOrderByEffectiveDateDesc(
            UUID ingredientId, String countryCode);
}
