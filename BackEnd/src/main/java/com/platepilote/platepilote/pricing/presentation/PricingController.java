package com.platepilote.platepilote.pricing.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.pricing.application.service.PricingService;
import com.platepilote.platepilote.pricing.domain.entity.BarcodeProduct;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/pricing")
@RequiredArgsConstructor
public class PricingController {

    private final PricingService pricingService;

    @GetMapping("/barcode/{barcode}")
    public ResponseEntity<ApiResponse<BarcodeProduct>> lookupBarcode(@PathVariable String barcode) {
        BarcodeProduct product = pricingService.lookupBarcode(barcode);
        return ResponseEntity.ok(ApiResponse.success(product));
    }
}
