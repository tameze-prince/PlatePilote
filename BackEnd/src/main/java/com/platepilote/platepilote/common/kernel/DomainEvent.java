package com.platepilote.platepilote.common.kernel;

/**
 * DOMAIN EVENT - EVENT TRACKING FOR DOMAIN CHANGES
 * ==================================================
 * 
 * WHAT IT IS:
 * Base class for events that happen in the system (e.g., "UserRegistered", "RecipeCreated").
 * 
 * WHY IT EXISTS:
 * When something important happens, we create an event. Other parts of the system
 * can listen for these events and react (e.g., send welcome email when user registers).
 * 
 * EXAMPLE:
 * public class UserRegisteredEvent extends DomainEvent {
 *     private final String email;
 *     public UserRegisteredEvent(String email) { this.email = email; }
 * }
 */

import java.time.Instant;
import java.util.UUID;

public abstract class DomainEvent {

    private final UUID eventId;
    private final Instant occurredOn;

    protected DomainEvent() {
        this.eventId = UUID.randomUUID();
        this.occurredOn = Instant.now();
    }

    public UUID getEventId() { return eventId; }
    public Instant getOccurredOn() { return occurredOn; }
    public abstract String getEventType();
}
