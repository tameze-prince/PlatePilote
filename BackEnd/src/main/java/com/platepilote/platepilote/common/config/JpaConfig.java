package com.platepilote.platepilote.common.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/**
 * Configuration JPA pour l'application.
 * Active l'audit automatique des entités via Spring Data JPA.
 */
@Configuration
@EnableJpaAuditing
public class JpaConfig {
}
