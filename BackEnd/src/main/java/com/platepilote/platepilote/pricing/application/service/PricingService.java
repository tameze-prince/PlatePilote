package com.platepilote.platepilote.pricing.application.service;

import com.platepilote.platepilote.common.kernel.ResourceNotFoundException;
import com.platepilote.platepilote.pricing.domain.entity.BarcodeProduct;
import com.platepilote.platepilote.pricing.domain.entity.IngredientPrice;
import com.platepilote.platepilote.pricing.domain.repository.BarcodeProductRepository;
import com.platepilote.platepilote.pricing.domain.repository.IngredientPriceRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class PricingService {

    private final IngredientPriceRepository ingredientPriceRepository;
    private final BarcodeProductRepository barcodeProductRepository;

    @Transactional(readOnly = true)
    public Optional<BigDecimal> getLatestPricePerUnit(UUID ingredientId, String countryCode) {
        return ingredientPriceRepository
                .findTopByIngredientIdAndCountryCodeOrderByEffectiveDateDesc(ingredientId, countryCode)
                .map(IngredientPrice::getAveragePricePerUnit);
    }

    @Transactional(readOnly = true)
    public List<IngredientPrice> getPriceHistory(UUID ingredientId) {
        return ingredientPriceRepository.findByIngredientId(ingredientId);
    }

    public IngredientPrice recordPrice(UUID ingredientId, BigDecimal price, String unit,
                                        String currencyCode, String countryCode, String source) {
        IngredientPrice record = IngredientPrice.builder()
                .ingredientId(ingredientId)
                .averagePricePerUnit(price)
                .unit(unit)
                .currencyCode(currencyCode)
                .countryCode(countryCode)
                .source(source)
                .effectiveDate(LocalDate.now())
                .build();
        return ingredientPriceRepository.save(record);
    }

    @Transactional(readOnly = true)
    public BarcodeProduct lookupBarcode(String barcode) {
        return barcodeProductRepository.findByBarcode(barcode)
                .orElseThrow(() -> new ResourceNotFoundException("BarcodeProduct", "barcode", barcode));
    }

    @Transactional(readOnly = true)
    public Optional<BarcodeProduct> findByOpenFoodFactsCode(String code) {
        return barcodeProductRepository.findByOpenFoodFactsCode(code);
    }

    public BarcodeProduct registerBarcodeProduct(BarcodeProduct product) {
        return barcodeProductRepository.save(product);
    }
}
