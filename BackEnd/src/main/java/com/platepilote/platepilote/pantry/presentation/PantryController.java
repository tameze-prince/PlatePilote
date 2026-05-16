package com.platepilote.platepilote.pantry.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.pantry.application.dto.PantryItemRequest;
import com.platepilote.platepilote.pantry.application.dto.PantryItemResponse;
import com.platepilote.platepilote.pantry.application.service.PantryService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/pantry")
@RequiredArgsConstructor
public class PantryController {

    private final PantryService pantryService;

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<PantryItemResponse>>> getAllItems(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PagedResponse<PantryItemResponse> items = pantryService.getAllItems(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<ApiResponse<List<PantryItemResponse>>> getItemsByCategory(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable String category) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        List<PantryItemResponse> items = pantryService.getItemsByCategory(userId, category);
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    @GetMapping("/expiring")
    public ResponseEntity<ApiResponse<List<PantryItemResponse>>> getExpiringItems(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "7") int days) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        List<PantryItemResponse> items = pantryService.getExpiringItems(userId, days);
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<List<PantryItemResponse>>> searchItems(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam String q) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        List<PantryItemResponse> items = pantryService.searchItems(userId, q);
        return ResponseEntity.ok(ApiResponse.success(items));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<PantryItemResponse>> addItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody PantryItemRequest request) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        PantryItemResponse item = pantryService.addItem(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Item added", item));
    }

    @PutMapping("/{itemId}")
    public ResponseEntity<ApiResponse<PantryItemResponse>> updateItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID itemId,
            @Valid @RequestBody PantryItemRequest request) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        PantryItemResponse item = pantryService.updateItem(userId, itemId, request);
        return ResponseEntity.ok(ApiResponse.success("Item updated", item));
    }

    @DeleteMapping("/{itemId}")
    public ResponseEntity<ApiResponse<Void>> removeItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID itemId) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        pantryService.removeItem(userId, itemId);
        return ResponseEntity.ok(ApiResponse.success("Item removed", null));
    }

    @PatchMapping("/{itemId}/consume")
    public ResponseEntity<ApiResponse<Void>> consumeItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID itemId,
            @RequestParam BigDecimal amount) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        pantryService.consumeItem(userId, itemId, amount);
        return ResponseEntity.ok(ApiResponse.success("Item consumed", null));
    }
}
