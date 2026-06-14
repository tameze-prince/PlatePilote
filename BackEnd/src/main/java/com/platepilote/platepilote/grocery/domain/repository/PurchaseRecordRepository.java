package com.platepilote.platepilote.grocery.domain.repository;

/**
 * Repository JPA pour l'entité {@link PurchaseRecord}.
 * <p>
 * Fournit l'accès à l'historique des achats d'un utilisateur,
 * trié par date d'achat décroissante.
 */
import com.platepilote.platepilote.grocery.domain.entity.PurchaseRecord;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.UUID;

public interface PurchaseRecordRepository extends JpaRepository<PurchaseRecord, UUID> {

    /**
     * Récupère l'historique des achats d'un utilisateur, trié du plus récent au plus ancien.
     *
     * @param userId   l'identifiant de l'utilisateur
     * @param pageable les paramètres de pagination
     * @return une page d'enregistrements d'achats
     */
    Page<PurchaseRecord> findByUserIdAndDeletedAtIsNullOrderByPurchasedAtDesc(UUID userId, Pageable pageable);
}
