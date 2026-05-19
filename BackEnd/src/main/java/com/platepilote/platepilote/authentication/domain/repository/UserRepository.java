package com.platepilote.platepilote.authentication.domain.repository;

/**
 * USER REPOSITORY - DATABASE ACCESS FOR USERS
 * =============================================
 * 
 * WHAT IT IS:
 * A Spring Data JPA repository interface for the User entity.
 * 
 * WHAT IT DOES:
 * Provides methods to query the "users" table in the database.
 * Spring Data JPA automatically implements these methods based on the method names.
 * 
 * METHOD EXPLANATION:
 * - findByEmail("john@email.com") -> SELECT * FROM users WHERE email = 'john@email.com'
 * - existsByEmail("john@email.com") -> SELECT COUNT(*) FROM users WHERE email = 'john@email.com' > 0
 * - findById(uuid) -> Inherited from JpaRepository, finds user by ID
 * - save(user) -> Inherited from JpaRepository, inserts or updates a user
 * - delete(user) -> Inherited from JpaRepository, deletes a user
 * 
 * NO NEED TO WRITE SQL:
 * Spring Data JPA generates the SQL automatically based on method names.
 * For complex queries, you can use @Query annotation.
 */

import com.platepilote.platepilote.authentication.domain.entity.OurUser;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository  // Tells Spring: "This is a data access bean"
public interface UserRepository extends JpaRepository<OurUser, UUID> {

    /**
     * Find a user by their email address.
     * Returns Optional<OurUser> - empty if no user found.
     * Used during login to load user details.
     */
    Optional<OurUser> findByEmail(String email);

    Optional<OurUser> findByProviderIgnoreCaseAndProviderId(String provider, String providerId);

    /**
     * Check if a user with this email already exists.
     * Used during registration to prevent duplicate accounts.
     */
    boolean existsByEmail(String email);

    @Query("SELECT u FROM OurUser u WHERE LOWER(u.email) LIKE LOWER(CONCAT('%', :query, '%')) " +
            "OR LOWER(u.firstName) LIKE LOWER(CONCAT('%', :query, '%')) " +
            "OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :query, '%'))")
    org.springframework.data.domain.Page<OurUser> search(@Param("query") String query, org.springframework.data.domain.Pageable pageable);
}
