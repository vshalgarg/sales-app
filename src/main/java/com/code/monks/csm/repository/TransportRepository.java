package com.code.monks.csm.repository;

import com.code.monks.csm.dto.response.TransportLiteResponseDto;
import com.code.monks.csm.entity.TransportEntity;
import com.code.monks.csm.enums.StatusEnum;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
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

  // Exact match (case-insensitive)
  boolean existsByNameIgnoreCase(String name);

  Optional<TransportEntity> findByNameIgnoreCase(String name);

  @EntityGraph(attributePaths = {"contacts"})
  @Query("""
    SELECT t FROM TransportEntity t
    WHERE t.status = :status
""")
  Page<TransportEntity> findAllActive(
          @Param("status") StatusEnum status,
          Pageable pageable
  );

  boolean existsByNameIgnoreCaseAndIdNot(String name, Integer excludeId);

  @Query("""
SELECT new com.code.monks.csm.dto.response.TransportLiteResponseDto(
    t.id,
    t.name
)
FROM TransportEntity t
WHERE t.status = com.code.monks.csm.enums.StatusEnum.ACTIVE
ORDER BY t.id DESC
""")
  List<TransportLiteResponseDto> findAllLite();

  @Query("""
            SELECT DISTINCT t
            FROM TransportEntity t
            LEFT JOIN FETCH t.contacts
            WHERE t.id = :id
            """)
  Optional<TransportEntity> findTransportDetailsById(Integer id);
}