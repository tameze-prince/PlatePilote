package com.platepilote.platepilote.ingredients.domain.repository;

import com.platepilote.platepilote.ingredients.domain.entity.Ingredient;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository d'accès aux données des ingrédients.
 * <p>
 * Table associée : {@code ingredients}.
 * </p>
 */
@Repository
public interface IngredientRepository extends JpaRepository<Ingredient, UUID> {

    /**
     * Recherche un ingrédient par son slug.
     *
     * @param slug slug de l'ingrédient
     * @return un {@code Optional} contenant l'ingrédient trouvé
     */
    Optional<Ingredient> findBySlug(String slug);

    /**
     * Recherche un ingrédient par son nom canonique.
     *
     * @param canonicalName nom canonique de l'ingrédient
     * @return un {@code Optional} contenant l'ingrédient trouvé
     */
    Optional<Ingredient> findByCanonicalName(String canonicalName);

    /**
     * Récupère les ingrédients actifs (non supprimés) d'une catégorie donnée, avec pagination.
     *
     * @param category catégorie d'ingrédients
     * @param pageable paramètres de pagination
     * @return page d'ingrédients de la catégorie
     */
    Page<Ingredient> findByCategoryAndDeletedAtIsNull(String category, Pageable pageable);

    /**
     * Recherche textuelle sur le nom canonique et la catégorie des ingrédients actifs.
     *
     * @param query    terme de recherche
     * @param pageable paramètres de pagination
     * @return page d'ingrédients correspondant à la recherche
     */
    @Query("SELECT i FROM Ingredient i WHERE i.deletedAt IS NULL AND " +
           "(LOWER(i.canonicalName) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(i.category) LIKE LOWER(CONCAT('%', :query, '%')))")
    Page<Ingredient> search(@Param("query") String query, Pageable pageable);

    /**
     * Recherche des ingrédients actifs par liste de noms canoniques (insensible à la casse).
     *
     * @param names    liste des noms canoniques
     * @param pageable paramètres de pagination
     * @return page d'ingrédients correspondant aux noms donnés
     */
    @Query("SELECT i FROM Ingredient i WHERE i.deletedAt IS NULL AND " +
           "LOWER(i.canonicalName) IN :names")
    Page<Ingredient> findByCanonicalNameInIgnoreCase(@Param("names") java.util.List<String> names, Pageable pageable);

    /**
     * Récupère les ingrédients actifs (non supprimés) correspondant à une liste d'identifiants.
     *
     * @param ids liste des identifiants
     * @return liste des ingrédients trouvés
     */
    @Query("SELECT i FROM Ingredient i WHERE i.id IN :ids AND i.deletedAt IS NULL")
    List<Ingredient> findAllByIdAndDeletedAtIsNull(@Param("ids") List<UUID> ids);
}
