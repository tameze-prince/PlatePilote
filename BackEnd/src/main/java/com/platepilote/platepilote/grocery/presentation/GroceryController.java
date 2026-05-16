package com.platepilote.platepilote.grocery.presentation;

import com.platepilote.platepilote.common.dto.ApiResponse;
import com.platepilote.platepilote.common.dto.PagedResponse;
import com.platepilote.platepilote.grocery.application.dto.GroceryItemRequest;
import com.platepilote.platepilote.grocery.application.dto.GroceryListRequest;
import com.platepilote.platepilote.grocery.application.service.GroceryService;
import com.platepilote.platepilote.grocery.application.service.GroceryService.GroceryListResponse;
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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/grocery-lists")
@RequiredArgsConstructor
public class GroceryController {

    private final GroceryService groceryService;

    @GetMapping
    public ResponseEntity<ApiResponse<PagedResponse<GroceryListResponse>>> getMyLists(
            @AuthenticationPrincipal UserDetails userDetails,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        PagedResponse<GroceryListResponse> lists = groceryService.getUserLists(userId, pageable);
        return ResponseEntity.ok(ApiResponse.success(lists));
    }

    @GetMapping("/{listId}")
    public ResponseEntity<ApiResponse<GroceryListResponse>> getList(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID listId) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        GroceryListResponse list = groceryService.getListById(userId, listId);
        return ResponseEntity.ok(ApiResponse.success(list));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<GroceryListResponse>> createList(
            @AuthenticationPrincipal UserDetails userDetails,
            @Valid @RequestBody GroceryListRequest request) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        GroceryListResponse list = groceryService.createList(userId, request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.success("Grocery list created", list));
    }

    @PostMapping("/{listId}/items")
    public ResponseEntity<ApiResponse<GroceryListResponse>> addItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID listId,
            @Valid @RequestBody GroceryItemRequest request) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        GroceryListResponse list = groceryService.addItem(userId, listId, request);
        return ResponseEntity.ok(ApiResponse.success("Item added", list));
    }

    @PatchMapping("/items/{itemId}/toggle")
    public ResponseEntity<ApiResponse<Void>> toggleItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID itemId) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        groceryService.toggleItemChecked(userId, itemId);
        return ResponseEntity.ok(ApiResponse.success("Item toggled", null));
    }

    @DeleteMapping("/items/{itemId}")
    public ResponseEntity<ApiResponse<Void>> removeItem(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID itemId) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        groceryService.removeItem(userId, itemId);
        return ResponseEntity.ok(ApiResponse.success("Item removed", null));
    }

    @PatchMapping("/{listId}/complete")
    public ResponseEntity<ApiResponse<Void>> completeList(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID listId) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        groceryService.completeList(userId, listId);
        return ResponseEntity.ok(ApiResponse.success("List completed", null));
    }

    @DeleteMapping("/{listId}")
    public ResponseEntity<ApiResponse<Void>> deleteList(
            @AuthenticationPrincipal UserDetails userDetails,
            @PathVariable UUID listId) {
        UUID userId = UUID.fromString(userDetails.getUsername());
        groceryService.deleteList(userId, listId);
        return ResponseEntity.ok(ApiResponse.success("List deleted", null));
    }
}
