-- V126__align_notifications_with_base_entity.sql
-- Notification extends BaseEntity, which requires updated_at and deleted_at.
-- Preserve existing notification rows while bringing the legacy table in line
-- with the JPA mapping.
ALTER TABLE notifications
    ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    ADD COLUMN deleted_at TIMESTAMP WITH TIME ZONE;
