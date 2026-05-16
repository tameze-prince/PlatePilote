package com.platepilote.platepilote.common.config;

/**
 * JPA CONFIGURATION - ENABLES AUDITING
 * =======================================
 * 
 * WHAT IT IS:
 * Enables Spring Data JPA Auditing.
 * 
 * WHAT IT DOES:
 * When you use @CreatedBy, @LastModifiedBy, @CreationTimestamp, @UpdateTimestamp
 * on entity fields, Spring automatically fills these values:
 * - @CreatedBy -> Filled with the currently authenticated user's email
 * - @LastModifiedBy -> Updated with the current user's email on each save
 * - @CreationTimestamp -> Set to NOW() when entity is first created
 * - @UpdateTimestamp -> Updated to NOW() every time entity is modified
 * 
 * WITHOUT THIS ANNOTATION:
 * You would have to manually set these fields every time you save an entity.
 */

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@Configuration
@EnableJpaAuditing
public class JpaConfig {
}
