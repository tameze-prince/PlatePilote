package com.platepilote.platepilote.preferences.domain.repository;

import com.platepilote.platepilote.preferences.domain.entity.CuisinePreference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CuisinePreferenceRepository extends JpaRepository<CuisinePreference, UUID> {

    List<CuisinePreference> findByUserId(UUID userId);
}
