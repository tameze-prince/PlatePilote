package com.platepilote.platepilote;

/**
 * Application PlatePilote — Point d'entrée principal.
 * <p>
 * Cette classe bootstrap le framework Spring Boot et démarre l'ensemble
 * du serveur backend. Elle active le cache, les tâches asynchrones,
 * la programmation de tâches et la lecture des propriétés de configuration.
 * <p>
 * L'application suit une architecture en modules DDD (Domain-Driven Design)
 * avec une séparation en trois couches par module :
 * <ul>
 *   <li><strong>domain</strong> : Entités (tables) + Repositories (accès base de données)</li>
 *   <li><strong>application</strong> : Services (logique métier) + DTOs</li>
 *   <li><strong>presentation</strong> : Contrôleurs REST (endpoints HTTP)</li>
 * </ul>
 * <p>
 * Exécution : {@code mvn spring-boot:run} ou depuis l'IDE (port 8081).
 */

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableConfigurationProperties
@EnableCaching
@EnableAsync
@EnableScheduling
public class PlatePiloteApplication {

    /**
     * Point d'entrée de l'application Spring Boot.
     * <p>
     * Initialise tous les beans, connecte la base de données PostgreSQL,
     * le cache Redis et démarre le serveur web embarqué.
     *
     * @param args arguments de la ligne de commande
     */
    public static void main(String[] args) {
        SpringApplication.run(PlatePiloteApplication.class, args);
    }
}
