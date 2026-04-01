package com.code.monks.csm.repository;

import com.code.monks.csm.dto.response.SupplierListResponseDto;
import com.code.monks.csm.dto.response.SupplierSummaryDto;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.entity.SupplierEntity;
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
public interface SupplierRepo extends JpaRepository<SupplierEntity,Integer> {
    @Query(value = "SELECT MAX(CAST(SUBSTRING(code, 2) AS UNSIGNED)) FROM supplier", nativeQuery = true)
    Integer findMaxCodeSuffix();

    Page<SupplierEntity> findAllByStatus(
            @Param("status") StatusEnum status,
            Pageable pageable
    );

    Optional<SupplierEntity> findOneByCode(String code);

    boolean existsByCode(String code);

    @Query(
            value = """
        SELECT DISTINCT s FROM SupplierEntity s
        LEFT JOIN s.contactList c
        WHERE s.status = com.code.monks.csm.enums.StatusEnum.ACTIVE AND (
            LOWER(s.supplierName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(s.gstNo) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(c.mobileNumber) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(s.city) LIKE LOWER(CONCAT('%', :keyword, '%'))
        )
        """,
            countQuery = """
        SELECT COUNT(DISTINCT s.id) FROM SupplierEntity s
        LEFT JOIN s.contactList c
        WHERE s.status = com.code.monks.csm.enums.StatusEnum.ACTIVE AND (
            LOWER(s.supplierName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(s.gstNo) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(c.mobileNumber) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(s.city) LIKE LOWER(CONCAT('%', :keyword, '%'))
        )
        """
    )
    Page<SupplierEntity> searchByKeyword(@Param("keyword") String keyword, Pageable pageable);


    @EntityGraph(attributePaths = {"contactList"})
    @Query("SELECT DISTINCT s FROM SupplierEntity s " +
            "LEFT JOIN s.contactList c " +
            "WHERE s.status = com.code.monks.csm.enums.StatusEnum.ACTIVE AND (" +
            "LOWER(s.supplierName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(s.gstNo) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(c.contactPerson) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(s.city) LIKE LOWER(CONCAT('%', :keyword, '%'))" +
            ")")
    List<SupplierEntity> searchByKeyword(@Param("keyword") String keyword);

    @Query("""
SELECT new com.code.monks.csm.dto.response.SupplierSummaryDto(
    s.id,
    s.supplierName,
    s.groupName,
    s.gstNo,
    s.msme,
    s.city
)
FROM SupplierEntity s
WHERE s.status = com.code.monks.csm.enums.StatusEnum.ACTIVE
ORDER BY s.supplierName
""")
    List<SupplierSummaryDto> findAllSummary();

    @Query("""
SELECT new com.code.monks.csm.dto.response.SupplierListResponseDto(
    s.id,
    s.code,
    s.supplierName,
    s.gstNo,
    CONCAT(s.addressLine1, ' ', s.addressLine2),
    s.city,
    c.mobileNumber
)
FROM SupplierEntity s
LEFT JOIN s.contactList c
WHERE s.status = :status
AND c.id = (
    SELECT MIN(c2.id) FROM ContactEntity c2 WHERE c2.supplier = s
)
""")
    Page<SupplierListResponseDto> findSupplierList(StatusEnum status, Pageable pageable);

}
