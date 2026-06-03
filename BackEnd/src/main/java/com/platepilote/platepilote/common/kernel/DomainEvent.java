package com.platepilote.platepilote.common.kernel;

/**
 * Classe de base pour les événements du domaine.
 * <p>
 * Chaque événement représente une action importante du système
 * (ex : {@code UserRegistered}, {@code RecipeCreated}).
 * D'autres parties du système peuvent écouter et réagir à ces événements.
 * </p>
 */
import java.time.Instant;
import java.util.UUID;

public abstract class DomainEvent {

    /** Identifiant unique de l'événement. */
    private final UUID eventId;
    /** Horodatage de survenue de l'événement. */
    private final Instant occurredOn;

    /** Crée un événement avec un identifiant unique et l'horodatage courant. */
    protected DomainEvent() {
        this.eventId = UUID.randomUUID();
        this.occurredOn = Instant.now();
    }

    /**
     * Retourne l'identifiant unique de l'événement.
     *
     * @return identifiant de l'événement
     */
    public UUID getEventId() { return eventId; }

    /**
     * Retourne l'horodatage de survenue de l'événement.
     *
     * @return horodatage de l'événement
     */
    public Instant getOccurredOn() { return occurredOn; }

    /**
     * Retourne le type d'événement (ex : "UserRegistered").
     *
     * @return type de l'événement
     */
    public abstract String getEventType();
}
