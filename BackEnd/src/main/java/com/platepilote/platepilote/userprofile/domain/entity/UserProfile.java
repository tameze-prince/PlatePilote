package com.platepilote.platepilote.userprofile.domain.entity;

/**
 * Entité représentant le profil utilisateur étendu.
 * <p>
 * Stocke les informations supplémentaires au-delà de l'authentification de base :
 * attributs physiques, objectifs de santé, préférences de localisation
 * et compétences culinaires. Chaque utilisateur possède exactement un profil
 * (relation one-to-one avec l'entité User).
 */

import com.platepilote.platepilote.common.kernel.AuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "user_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserProfile extends AuditableEntity {

    /** Identifiant de l'utilisateur (foreign key vers User, unique). */
    @Column(name = "user_id", nullable = false, unique = true)
    private UUID userId;

    /** Date de naissance utilisée pour les calculs nutritionnels. */
    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    /** Genre (affecte les calculs de calories et nutriments). */
    @Column(name = "gender")
    private String gender;

    /** Taille en centimètres. */
    @Column(name = "height_cm")
    private BigDecimal heightCm;

    /** Poids en kilogrammes. */
    @Column(name = "weight_kg")
    private BigDecimal weightKg;

    /** Niveau d'activité physique : Sédentaire, Léger, Modéré, Actif, Très actif. */
    @Column(name = "activity_level")
    private String activityLevel;

    /** Objectifs de santé (texte libre). */
    @Column(name = "health_goals", columnDefinition = "TEXT")
    private String healthGoals;

    /** Code pays ISO 3166-1 alpha-2 (défaut: US). */
    @Column(name = "country_code", length = 2)
    private String countryCode;

    /** Code devise ISO 4217 (défaut: USD). */
    @Column(name = "currency_code", length = 4)
    private String currencyCode;

    /** Locale (défaut: en-US). */
    @Column(name = "locale", length = 20)
    private String locale;

    /** Niveau de compétence culinaire (défaut: BEGINNER). */
    @Column(name = "cooking_skill", length = 20)
    private String cookingSkill;

    /** Taille du foyer (défaut: 1). */
    @Column(name = "household_size")
    private Integer householdSize;
}
