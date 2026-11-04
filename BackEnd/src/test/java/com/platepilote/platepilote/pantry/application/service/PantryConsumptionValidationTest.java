package com.platepilote.platepilote.pantry.application.service;

import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.ingredients.application.service.IngredientResolutionService;
import com.platepilote.platepilote.pantry.domain.entity.PantryItem;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.Optional;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.verifyNoInteractions;

class PantryConsumptionValidationTest {

    @Test
    void rejectsZeroConsumptionBeforeReadingPantryItem() {
        PantryItemRepository repository = mock(PantryItemRepository.class);
        PantryService service = new PantryService(
                repository,
                mock(IngredientResolutionService.class),
                mock(SecurityUtils.class));

        assertThatThrownBy(() -> service.consumeItem(UUID.randomUUID(), UUID.randomUUID(), BigDecimal.ZERO))
                .isInstanceOf(BusinessRuleViolationException.class);
        verifyNoInteractions(repository);
    }

    @Test
    void rejectsNegativeConsumptionBeforeReadingPantryItem() {
        PantryItemRepository repository = mock(PantryItemRepository.class);
        PantryService service = new PantryService(
                repository,
                mock(IngredientResolutionService.class),
                mock(SecurityUtils.class));

        assertThatThrownBy(() -> service.consumeItem(UUID.randomUUID(), UUID.randomUUID(), BigDecimal.valueOf(-2)))
                .isInstanceOf(BusinessRuleViolationException.class);
        verifyNoInteractions(repository);
    }

    @Test
    void rejectsConsumptionGreaterThanAvailableQuantity() {
        UUID userId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();
        PantryItem item = PantryItem.builder()
                .userId(userId)
                .name("Rice")
                .quantity(BigDecimal.ONE)
                .unit("kg")
                .build();
        PantryItemRepository repository = mock(PantryItemRepository.class);
        when(repository.findById(itemId)).thenReturn(Optional.of(item));
        PantryService service = new PantryService(
                repository,
                mock(IngredientResolutionService.class),
                mock(SecurityUtils.class));

        assertThatThrownBy(() -> service.consumeItem(userId, itemId, BigDecimal.valueOf(2)))
                .isInstanceOf(BusinessRuleViolationException.class);
        verify(repository, never()).save(item);
    }

    @Test
    void rejectsNullConsumptionBeforeReadingPantryItem() {
        PantryItemRepository repository = mock(PantryItemRepository.class);
        PantryService service = new PantryService(
                repository,
                mock(IngredientResolutionService.class),
                mock(SecurityUtils.class));

        assertThatThrownBy(() -> service.consumeItem(UUID.randomUUID(), UUID.randomUUID(), null))
                .isInstanceOf(BusinessRuleViolationException.class);
        verifyNoInteractions(repository);
    }
}
