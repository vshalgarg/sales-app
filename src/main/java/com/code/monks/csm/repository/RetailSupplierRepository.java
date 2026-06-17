package com.code.monks.csm.repository;

import com.code.monks.csm.entity.RetailSupplierEntity;
import com.code.monks.csm.enums.StatusEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface RetailSupplierRepository extends JpaRepository<RetailSupplierEntity, Integer> {

    @Modifying
    @Query("""
    update RetailSupplierEntity rs
    set rs.status = :status
    where rs.retail.id = :retailId
""")
    int updateRetailSupplierStatus(
            @Param("retailId") Long retailId,
            @Param("status") StatusEnum status
    );

    Optional<RetailSupplierEntity> findByIdAndRetailId(
            Integer id,
            Integer retailId
    );

    boolean existsByRetailIdAndSupplierIdAndStatus(
            Integer retailId,
            Integer supplierId,
            StatusEnum status
    );
}
