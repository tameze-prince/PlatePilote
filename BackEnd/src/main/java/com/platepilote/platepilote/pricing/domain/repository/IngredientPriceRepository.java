package com.platepilote.platepilote.pricing.domain.repository;

import com.platepilote.platepilote.pricing.domain.entity.IngredientPrice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface IngredientPriceRepository extends JpaRepository<IngredientPrice, UUID> {

    List<IngredientPrice> findByIngredientId(UUID ingredientId);

    Optional<IngredientPrice> findTopByIngredientIdAndCountryCodeOrderByEffectiveDateDesc(
            UUID ingredientId, String countryCode);

    @Query(value = """
            SELECT DISTINCT ON (ingredient_id) *
            FROM ingredient_prices
            WHERE ingredient_id IN (:ingredientIds)
              AND country_code = :countryCode
            ORDER BY ingredient_id, effective_date DESC
            """, nativeQuery = true)
    List<IngredientPrice> findLatestByIngredientIdsAndCountryCode(
            @Param("ingredientIds") List<UUID> ingredientIds,
            @Param("countryCode") String countryCode);
}
