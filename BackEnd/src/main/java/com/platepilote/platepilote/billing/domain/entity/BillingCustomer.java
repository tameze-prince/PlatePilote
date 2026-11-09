package com.platepilote.platepilote.billing.domain.entity;

import com.platepilote.platepilote.common.kernel.BaseEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.UUID;

/**
 * Entité représentant un client de facturation chez un fournisseur de paiement.
 * Table en base : {@code billing_customers}.
 */
@Entity
@Table(name = "billing_customers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BillingCustomer extends BaseEntity {

    /** Identifiant de l'utilisateur associé. */
    @Column(name = "user_id", nullable = false)
    private UUID userId;

    /** Nom du fournisseur de paiement (ex. STRIPE). */
    @Column(nullable = false, length = 40)
    private String provider;

    /** Identifiant du client chez le fournisseur. */
    @Column(name = "provider_customer_id", nullable = false, length = 255)
    private String providerCustomerId;

    /** Email du client. */
    @Column(length = 255)
    private String email;
}
