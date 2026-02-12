package com.code.monks.csm.repository;

import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.entity.SupplierEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SupplierRepo extends JpaRepository<SupplierEntity,Integer> {
    @Query(value = "SELECT MAX(CAST(SUBSTRING(code, 2, 3) AS UNSIGNED)) FROM supplier", nativeQuery = true)
    Integer findMaxCodeSuffix();

    SupplierEntity findBySupplierName(String SupplierName);

    //Page<SupplierEntity> findAllByStatus(Pageable pageable, StatusEnum status);

    Page<SupplierEntity> findAllByStatus(
            @Param("status") StatusEnum status,
            Pageable pageable
    );

    Optional<SupplierEntity> findOneByCode(String code);

    boolean existsByGstNo(String gstNo);

    boolean existsByCode(String code);

    //List<SupplierEntity> findBySupplierNameContainingIgnoreCaseAndStatus(String keyword,StatusEnum status);

    @Query(value = "SELECT DISTINCT s FROM SupplierEntity s " +
            "LEFT JOIN s.contactList c " +
            "WHERE s.status = com.code.monks.csm.enums.StatusEnum.ACTIVE AND (" +
            "LOWER(s.supplierName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(s.gstNo) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(c.contactPerson) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(s.city) LIKE LOWER(CONCAT('%', :keyword, '%'))" +
            ")",
            countQuery = "SELECT COUNT(DISTINCT s.id) FROM SupplierEntity s " +
                    "LEFT JOIN s.contactList c " +
                    "WHERE s.status = com.code.monks.csm.enums.StatusEnum.ACTIVE AND (" +
                    "LOWER(s.supplierName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
                    "LOWER(s.gstNo) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
                    "LOWER(c.contactPerson) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
                    "LOWER(s.city) LIKE LOWER(CONCAT('%', :keyword, '%'))" +
                    ")")
    Page<SupplierEntity> searchByKeyword(@Param("keyword") String keyword, Pageable pageable);


    @Query("SELECT DISTINCT s FROM SupplierEntity s " +
            "LEFT JOIN s.contactList c " +
            "WHERE s.status = com.code.monks.csm.enums.StatusEnum.ACTIVE AND (" +
            "LOWER(s.supplierName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(s.gstNo) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(c.contactPerson) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(s.city) LIKE LOWER(CONCAT('%', :keyword, '%'))" +
            ")")
    List<SupplierEntity> searchByKeyword(@Param("keyword") String keyword);


    boolean existsBySupplierNameIgnoreCaseAndStatus(String trim, StatusEnum statusEnum);

    boolean existsBySupplierNameIgnoreCaseAndIdNot(String trim, Integer currentId);
}
