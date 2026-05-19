package com.platepilote.platepilote.authentication.domain.repository;

import com.platepilote.platepilote.authentication.domain.entity.RefreshToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.Instant;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {

    Optional<RefreshToken> findByToken(String token);

    @Modifying
    @Query("update RefreshToken rt set rt.revoked = true where rt.userId = :userId and rt.revoked = false")
    int revokeAllActiveForUser(@Param("userId") UUID userId);

    @Modifying
    @Query("delete from RefreshToken rt where rt.expiresAt < :before or rt.revoked = true")
    int deleteExpiredOrRevokedBefore(@Param("before") Instant before);
}
