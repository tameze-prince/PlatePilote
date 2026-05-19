package com.platepilote.platepilote.authentication.domain.repository;

import com.platepilote.platepilote.authentication.domain.entity.EmailVerificationToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface EmailVerificationTokenRepository extends JpaRepository<EmailVerificationToken, UUID> {

    Optional<EmailVerificationToken> findByToken(String token);

    @Modifying
    @Query("UPDATE EmailVerificationToken t SET t.used = true WHERE t.userId = :userId AND t.used = false")
    void markActiveTokensUsedForUser(@Param("userId") UUID userId);
}
