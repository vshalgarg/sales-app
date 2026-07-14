package com.code.monks.csm.repository;

import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.enums.StatusEnum;
import jakarta.validation.constraints.NotNull;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Sort;

@Repository
public interface SupplierRepo extends JpaRepository<SupplierEntity,Integer> {
    @Query(value = "SELECT MAX(CAST(SUBSTRING(code, 2) AS UNSIGNED)) FROM supplier", nativeQuery = true)
    Integer findMaxCodeSuffix();

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
    @Query("""
SELECT s FROM SupplierEntity s
WHERE s.status = :status
""")
    Page<SupplierEntity> findSupplierList(StatusEnum status, Pageable pageable);
    Optional<SupplierEntity> findByIdAndStatus(@NotNull(message = "Supplier Id is required") Integer integer, StatusEnum statusEnum);
    List<SupplierEntity> findByStatus(StatusEnum status, Sort sort);
}
