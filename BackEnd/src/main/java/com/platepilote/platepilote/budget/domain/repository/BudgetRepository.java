package com.platepilote.platepilote.budget.domain.repository;

import com.platepilote.platepilote.budget.domain.entity.Budget;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface BudgetRepository extends JpaRepository<Budget, UUID> {

    Page<Budget> findByUserIdAndDeletedAtIsNull(UUID userId, Pageable pageable);
}
