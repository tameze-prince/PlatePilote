package com.platepilote.platepilote.userprofile.application.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

/**
 * DTO de réponse pour le profil utilisateur.
 * <p>
 * Contient l'ensemble des informations du profil exposées via l'API REST.
 */
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {

    /** Identifiant unique du profil. */
    private UUID id;

    /** Identifiant de l'utilisateur associé. */
    private UUID userId;

    /** Prénom de l'utilisateur. */
    private String firstName;

    /** Nom de famille de l'utilisateur. */
    private String lastName;

    /** Date de naissance. */
    private LocalDate dateOfBirth;

    /** Genre. */
    private String gender;

    /** Taille en centimètres. */
    private BigDecimal heightCm;

    /** Poids en kilogrammes. */
    private BigDecimal weightKg;

    /** Niveau d'activité physique. */
    private String activityLevel;

    /** Objectifs de santé. */
    private String healthGoals;

    /** Code pays ISO 3166-1 alpha-2. */
    private String countryCode;

    /** Code devise ISO 4217. */
    private String currencyCode;

    /** Locale (ex: fr-FR, en-US). */
    private String locale;

    /** Niveau de compétence culinaire. */
    private String cookingSkill;

    /** Taille du foyer. */
    private Integer householdSize;

    /** Date de création du profil. */
    private Instant createdAt;

    /** Date de dernière modification du profil. */
    private Instant updatedAt;
}
