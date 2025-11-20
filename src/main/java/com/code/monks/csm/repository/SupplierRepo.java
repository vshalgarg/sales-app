package com.code.monks.csm.repository;

import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.entity.SupplierEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface SupplierRepo extends JpaRepository<SupplierEntity,Integer> {
    @Query(value = "SELECT MAX(CAST(SUBSTRING(code, 2, 3) AS UNSIGNED)) FROM Supplier", nativeQuery = true)
    Integer findMaxCodeSuffix();

    SupplierEntity findBySupplierName(String SupplierName);

    Page<SupplierEntity> findAllByStatus(Pageable pageable, StatusEnum status);

    Optional<SupplierEntity> findOneByCode(String code);

    boolean existsByGstNo(String gstNo);

    boolean existsByCode(String code);

    List<SupplierEntity> findBySupplierNameContainingIgnoreCaseAndStatus(String keyword,StatusEnum status);

}
