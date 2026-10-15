package com.code.monks.csm.repository;

import com.code.monks.csm.entity.RetailSupplierDepositEntity;
import com.code.monks.csm.enums.StatusEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
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


        @Query("""
        SELECT DISTINCT d.retailSupplier.retail.id
        FROM RetailSupplierDepositEntity d
        WHERE d.depositDate >= :startDate
          AND d.depositDate < :endDate
          AND d.retailSupplier IS NOT NULL
          AND d.retailSupplier.retail IS NOT NULL
        """)
        List<Integer> findDistinctRetailerIdsByDepositDate(
                @Param("startDate") LocalDate startDate,
                @Param("endDate") LocalDate endDate);

        @Query("""
        SELECT DISTINCT d.retailSupplier.supplier.id
        FROM RetailSupplierDepositEntity d
        WHERE d.depositDate >= :startDate
          AND d.depositDate < :endDate
          AND d.retailSupplier IS NOT NULL
          AND d.retailSupplier.supplier IS NOT NULL
        """)
        List<Integer> findDistinctSupplierIdsByDepositDate(
                @Param("startDate") LocalDate startDate,
                @Param("endDate") LocalDate endDate);


}
