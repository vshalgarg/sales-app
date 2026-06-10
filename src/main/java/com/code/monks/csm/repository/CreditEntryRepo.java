package com.code.monks.csm.repository;

import com.code.monks.csm.dto.analytics.projection.CountView;
import com.code.monks.csm.dto.analytics.projection.MonthlyAmountView;
import com.code.monks.csm.entity.CreditEntryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CreditEntryRepo extends JpaRepository<CreditEntryEntity,Integer>,
        JpaSpecificationExecutor<CreditEntryEntity> {

    boolean existsByReferenceNumber(String referenceNumber);


    @Query("""
        SELECT new com.code.monks.csm.dto.analytics.projection.MonthlyAmountView(
            YEAR(c.date),
            MONTH(c.date),
            COALESCE(SUM(c.receivedAmount), 0)
        )
        FROM CreditEntryEntity c
        WHERE
            c.date IS NOT NULL
            AND (:supplierIds IS NULL OR c.supplierId IN :supplierIds)
            AND (:customerIds IS NULL OR c.customerId IN :customerIds)
        GROUP BY YEAR(c.date), MONTH(c.date)
        ORDER BY YEAR(c.date), MONTH(c.date)
        """)
    List<MonthlyAmountView> getMonthlyCreditAmount(
            @Param("supplierIds") List<Integer> supplierIds,
            @Param("customerIds") List<Integer> customerIds
    );

    @Query("""
        SELECT new com.code.monks.csm.dto.analytics.projection.CountView(
            YEAR(c.date),
            MONTH(c.date),
            COALESCE(COUNT(c.id), 0)
        )
        FROM CreditEntryEntity c
        WHERE
            c.date IS NOT NULL
            AND (:supplierIds IS NULL OR c.supplierId IN :supplierIds)
            AND (:customerIds IS NULL OR c.customerId IN :customerIds)
        GROUP BY YEAR(c.date), MONTH(c.date)
        ORDER BY YEAR(c.date), MONTH(c.date)
        """)
    List<CountView> getMonthlyCreditEntryCount(
            @Param("supplierIds") List<Integer> supplierIds,
            @Param("customerIds") List<Integer> customerIds
    );
}
