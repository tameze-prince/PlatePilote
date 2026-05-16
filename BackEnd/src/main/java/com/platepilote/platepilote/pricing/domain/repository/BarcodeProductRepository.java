package com.platepilote.platepilote.pricing.domain.repository;

import com.platepilote.platepilote.pricing.domain.entity.BarcodeProduct;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface BarcodeProductRepository extends JpaRepository<BarcodeProduct, UUID> {

    Optional<BarcodeProduct> findByBarcode(String barcode);

    Optional<BarcodeProduct> findByOpenFoodFactsCode(String openFoodFactsCode);
}
