package com.platepilote.platepilote.recommendation.domain.repository;

import com.platepilote.platepilote.recommendation.domain.entity.UserInteraction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface UserInteractionRepository extends JpaRepository<UserInteraction, UUID> {

    List<UserInteraction> findByUserIdAndCreatedAtAfter(UUID userId, Instant createdAt);
}
