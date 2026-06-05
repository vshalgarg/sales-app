package com.code.monks.csm.repository;

import com.code.monks.csm.entity.RetailSupplierEntity;
import com.code.monks.csm.enums.StatusEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface RetailSupplierRepository extends JpaRepository<RetailSupplierEntity, Integer> {

    @Modifying
    @Query("""
    update RetailSupplierEntity rs
    set rs.status = :status
    where rs.retail.id = :retailId
""")
    int updateRetailSupplierStatus(
            Long retailId,
            StatusEnum status
    );

    Optional<RetailSupplierEntity> findByIdAndRetailId(
            Integer id,
            Integer retailId
    );
}
