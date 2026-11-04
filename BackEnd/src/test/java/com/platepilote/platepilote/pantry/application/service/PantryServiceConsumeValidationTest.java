package com.platepilote.platepilote.pantry.application.service;

import com.platepilote.platepilote.common.kernel.BusinessRuleViolationException;
import com.platepilote.platepilote.common.security.SecurityUtils;
import com.platepilote.platepilote.ingredients.application.service.IngredientResolutionService;
import com.platepilote.platepilote.pantry.domain.repository.PantryItemRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;

@ExtendWith(MockitoExtension.class)
class PantryServiceConsumeValidationTest {

    @Mock private PantryItemRepository pantryItemRepository;
    @Mock private IngredientResolutionService ingredientResolutionService;
    @Mock private SecurityUtils securityUtils;

    private PantryService pantryService;

    @BeforeEach
    void setUp() {
        pantryService = new PantryService(
                pantryItemRepository,
                ingredientResolutionService,
                securityUtils
        );
    }

    @Test
    void rejectsNullZeroAndNegativeConsumptionBeforeReadingStock() {
        UUID userId = UUID.randomUUID();
        UUID itemId = UUID.randomUUID();

        assertThatThrownBy(() -> pantryService.consumeItem(userId, itemId, null))
                .isInstanceOf(BusinessRuleViolationException.class);
        assertThatThrownBy(() -> pantryService.consumeItem(userId, itemId, BigDecimal.ZERO))
                .isInstanceOf(BusinessRuleViolationException.class);
        assertThatThrownBy(() -> pantryService.consumeItem(userId, itemId, new BigDecimal("-1")))
                .isInstanceOf(BusinessRuleViolationException.class);

        verify(pantryItemRepository, never()).findById(itemId);
    }
}
