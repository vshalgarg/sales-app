package com.code.monks.csm.repository;

import com.code.monks.csm.entity.TransportEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TransportRepository extends JpaRepository<TransportEntity, Integer> {

  @Query("SELECT t FROM TransportEntity t WHERE LOWER(t.name) LIKE LOWER(CONCAT('%', :query, '%')) AND t.isActive = true ORDER BY t.name")
  List<TransportEntity> searchByName(String query);

  List<TransportEntity> findAllByIsActiveTrueOrderByNameAsc();
  // Exact match (case-insensitive)
  boolean existsByNameIgnoreCase(String name);

  Optional<TransportEntity> findByNameIgnoreCase(String name);

}