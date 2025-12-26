package com.code.monks.csm.repository;

import com.code.monks.csm.entity.TransportEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TransportRepository extends JpaRepository<TransportEntity, Integer> {

  @Query("SELECT t FROM TransportEntity t " +
          "WHERE t.isActive = true " +
          "AND LOWER(t.name) LIKE LOWER(CONCAT('%', :query, '%'))")
  Page<TransportEntity> searchByName(@Param("query") String query, Pageable pageable);

  List<TransportEntity> findAllByIsActiveTrueOrderByNameAsc();
  // Exact match (case-insensitive)
  boolean existsByNameIgnoreCase(String name);

  Optional<TransportEntity> findByNameIgnoreCase(String name);
  Page<TransportEntity> findAllByIsActiveTrue(Pageable pageable);


}