package com.platepilote.platepilote;

/**
 * PLATEPILOTE APPLICATION - MAIN ENTRY POINT
 * =============================================
 * 
 * This is the main Spring Boot application class. When you run this class,
 * it starts the entire backend server.
 * 
 * WHAT IT DOES:
 * - Bootstraps the Spring Boot framework
 * - Scans all packages under com.platepilote.platepilote for components
 * - Starts the embedded Tomcat web server on port 8080
 * - Connects to PostgreSQL database
 * - Connects to Redis cache
 * 
 * HOW TO RUN:
 * - From IDE: Right-click this file -> Run
 * - From terminal: mvn spring-boot:run
 * 
 * PROJECT STRUCTURE OVERVIEW:
 * 
 * com.platepilote.platepilote/
 * ├── common/                    <- SHARED UTILITIES (used by all modules)
 * │   ├── kernel/                <- Core DDD building blocks (BaseEntity, exceptions, value objects)
 * │   ├── security/              <- JWT authentication & Spring Security config
 * │   ├── config/                <- Global configurations (CORS, JPA, Swagger)
 * │   ├── exception/             <- Global error handler
 * │   └── dto/                   <- Common API response wrappers
 * │
 * ├── authentication/            <- USER LOGIN & REGISTRATION MODULE
 * │   ├── domain/                <- Business logic & data models
 * │   │   ├── entity/            <- Database entities (User, Role)
 * │   │   └── repository/        <- Database access interfaces
 * │   ├── application/           <- Application services (business rules)
 * │   │   ├── dto/               <- Request/Response data transfer objects
 * │   │   └── service/           <- Service classes with business logic
 * │   └── presentation/          <- REST API controllers (HTTP endpoints)
 * │
 * ├── userprofile/               <- USER PROFILE MODULE (height, weight, goals)
 * ├── preferences/               <- PREFERENCES MODULE (diet, allergies)
 * ├── pantry/                    <- PANTRY MODULE (food inventory)
 * ├── recipes/                   <- RECIPES MODULE (recipes, ingredients, steps)
 * ├── mealplanning/              <- MEAL PLANNING MODULE (weekly plans)
 * ├── grocery/                   <- GROCERY MODULE (shopping lists)
 * └── recommendation/            <- RECOMMENDATION MODULE (recipe suggestions)
 * 
 * Each module follows the same 3-layer pattern:
 *   domain/     -> Entities (database tables) + Repositories (database queries)
 *   application -> Services (business logic) + DTOs (data transfer objects)
 *   presentation -> Controllers (REST API endpoints)
 */

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties
public class PlatePiloteApplication {

    public static void main(String[] args) {
        // This line starts the entire Spring Boot application
        // It initializes all beans, connects to database, and starts the web server
        SpringApplication.run(PlatePiloteApplication.class, args);
    }
}
