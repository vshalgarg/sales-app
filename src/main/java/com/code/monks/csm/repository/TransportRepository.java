package com.code.monks.csm.repository;

import com.code.monks.csm.entity.TransportEntity;
import com.code.monks.csm.enums.StatusEnum;
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

  @Query("""
    SELECT t FROM TransportEntity t
    WHERE t.status = :status
      AND (
            LOWER(t.name) LIKE LOWER(CONCAT('%', :query, '%'))
         OR LOWER(t.city) LIKE LOWER(CONCAT('%', :query, '%'))
         OR LOWER(t.gstNo) LIKE LOWER(CONCAT('%', :query, '%'))
      )
""")
  Page<TransportEntity> searchByKeyword(
          @Param("query") String query,
          @Param("status") StatusEnum status,
          Pageable pageable
  );

  // List<TransportEntity> findAllByIsActiveTrueOrderByNameAsc();
  // Exact match (case-insensitive)
  boolean existsByNameIgnoreCase(String name);

  Optional<TransportEntity> findByNameIgnoreCase(String name);

  // only ACTIVE + INACTIVE (DELETE exclude)
    Page<TransportEntity> findAllByStatusNot(StatusEnum statusEnum, Pageable pageable);


  boolean existsByGstNoIgnoreCase(String gst);


  boolean existsByNameIgnoreCaseAndIdNot(String name, Integer excludeId);

  boolean existsByGstNoIgnoreCaseAndIdNot(String gst, Integer excludeId);

    boolean existsByEmail(String email);

  boolean existsByEmailAndIdNot(String email, Integer excludeId);

  boolean existsByGstNo(String gst);

  boolean existsByGstNoAndIdNot(String gst, Integer excludeId);
}