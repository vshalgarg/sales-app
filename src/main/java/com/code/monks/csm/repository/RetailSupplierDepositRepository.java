package com.code.monks.csm.repository;

import com.code.monks.csm.entity.RetailSupplierDepositEntity;
import com.code.monks.csm.enums.StatusEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface RetailSupplierDepositRepository extends JpaRepository<RetailSupplierDepositEntity, Integer> {

    @Query("""
    select d
    from RetailSupplierDepositEntity d
    where d.retailSupplier.id in :ids
    and d.status = :status
""")
    List<RetailSupplierDepositEntity> findByRetailSupplierIdsAndStatus(
            List<Integer> ids,
            StatusEnum status
    );

    @Modifying
    @Query(value = """
    update retail_supplier_deposits d
    join retail_supplier rs
        on rs.id = d.retail_supplier_id
    set d.status = :status
    where rs.retail_id = :retailId
    """,
            nativeQuery = true)
    int updateDepositStatus(
            @Param("retailId") Long retailId,
            @Param("status") StatusEnum status
    );
}
