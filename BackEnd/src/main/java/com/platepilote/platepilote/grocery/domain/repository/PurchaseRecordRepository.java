package com.platepilote.platepilote.grocery.domain.repository;

import com.platepilote.platepilote.grocery.domain.entity.PurchaseRecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface PurchaseRecordRepository extends JpaRepository<PurchaseRecord, UUID> {

    Page<PurchaseRecord> findByUserIdAndDeletedAtIsNullOrderByPurchasedAtDesc(UUID userId, Pageable pageable);
}
