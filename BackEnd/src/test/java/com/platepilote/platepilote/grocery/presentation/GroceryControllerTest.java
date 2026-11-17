package com.platepilote.platepilote.grocery.presentation;

import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.grocery.application.dto.GroceryItemRequest;
import com.platepilote.platepilote.grocery.application.dto.GroceryListRequest;
import com.platepilote.platepilote.grocery.application.service.GroceryService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.userdetails.UserDetails;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GroceryControllerTest {

    @Mock private GroceryService groceryService;
    @Mock private SecurityUtils securityUtils;
    @Mock private UserDetails userDetails;

    @Test
    void delegatesAllAuthenticatedGroceryEndpointsToTheService() {
        UUID userId = UUID.randomUUID();
        UUID listId = UUID.randomUUID();
        UUID mealPlanId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        when(securityUtils.getCurrentUserId(userDetails)).thenReturn(userId);

        GroceryController controller = new GroceryController(groceryService, securityUtils);

        assertThat(controller.getMyLists(userDetails, 0, 20).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.getList(userDetails, listId).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.generateFromMealPlan(userDetails, mealPlanId).getStatusCode())
                .isEqualTo(HttpStatus.CREATED);
        assertThat(controller.createList(userDetails, GroceryListRequest.builder().name("Weekly").build())
                .getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(controller.addItem(userDetails, listId, GroceryItemRequest.builder()
                .name("Rice").quantity(new BigDecimal("2")).unit("kg").build()).getStatusCode())
                .isEqualTo(HttpStatus.OK);
        assertThat(controller.toggleItem(userDetails, itemId).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.removeItem(userDetails, itemId).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.completeList(userDetails, listId).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.checkoutList(userDetails, listId,
                new GroceryController.CheckoutRequest(List.of(itemId), Map.of(itemId, new BigDecimal("2.50"))))
                .getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.getPurchaseHistory(userDetails, 0, 20).getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(controller.deleteList(userDetails, listId).getStatusCode()).isEqualTo(HttpStatus.OK);

        verify(groceryService).getUserLists(eq(userId), any(Pageable.class));
        verify(groceryService).getListById(userId, listId);
        verify(groceryService).generateFromMealPlan(userId, mealPlanId);
        verify(groceryService).createList(eq(userId), any(GroceryListRequest.class));
        verify(groceryService).addItem(eq(userId), eq(listId), any(GroceryItemRequest.class));
        verify(groceryService).toggleItemChecked(userId, itemId);
        verify(groceryService).removeItem(userId, itemId);
        verify(groceryService).completeList(userId, listId);
        verify(groceryService).checkoutList(eq(userId), eq(listId), eq(List.of(itemId)),
                eq(Map.of(itemId, new BigDecimal("2.50"))));
        verify(groceryService).getPurchaseHistory(eq(userId), any(Pageable.class));
        verify(groceryService).deleteList(userId, listId);
    }
}
