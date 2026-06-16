package com.code.monks.csm.repository;

import com.code.monks.csm.dto.analytics.projection.MonthlyAnalyticsView;
import com.code.monks.csm.dto.analytics.projection.CustomerAmountView;
import com.code.monks.csm.dto.analytics.projection.SupplierAmountView;
import com.code.monks.csm.entity.CreditEntryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface CreditEntryRepo extends JpaRepository<CreditEntryEntity,Integer>,
        JpaSpecificationExecutor<CreditEntryEntity> {

    boolean existsByReferenceNumber(String referenceNumber);

    List<CreditEntryEntity> findBySupplierIdAndCustomerId(
            Integer supplierId,
            Integer customerId
    );

    @Query("""
    SELECT
        YEAR(c.date) as year,
        MONTH(c.date) as month,
        COALESCE(SUM(c.receivedAmount), 0) as amount,
        COALESCE(COUNT(c.id), 0) as count
    FROM CreditEntryEntity c
    WHERE
        c.date IS NOT NULL
        AND (:supplierIds IS NULL OR c.supplierId IN :supplierIds)
        AND (:customerIds IS NULL OR c.customerId IN :customerIds)
        AND (:fromDate IS NULL OR c.date >= :fromDate)
        AND (:toDate IS NULL OR c.date <= :toDate)
    GROUP BY YEAR(c.date), MONTH(c.date)
    ORDER BY YEAR(c.date), MONTH(c.date)
""")
    List<MonthlyAnalyticsView> getMonthlyCreditAnalytics(
            @Param("supplierIds") List<Integer> supplierIds,
            @Param("customerIds") List<Integer> customerIds,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate
    );

    @Query("""
    SELECT c.supplierId as supplierId, COALESCE(SUM(c.receivedAmount), 0) as amount
    FROM CreditEntryEntity c
    WHERE (:supplierIds IS NULL OR c.supplierId IN :supplierIds)
      AND (:fromDate IS NULL OR c.date >= :fromDate)
      AND (:toDate IS NULL OR c.date <= :toDate)
    GROUP BY c.supplierId
""")
    List<SupplierAmountView> getSupplierCreditAnalytics(
            @Param("supplierIds") List<Integer> supplierIds,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate
    );

    @Query("""
    SELECT c.customerId as customerId, COALESCE(SUM(c.receivedAmount), 0) as amount
    FROM CreditEntryEntity c
    WHERE (:customerIds IS NULL OR c.customerId IN :customerIds)
      AND (:fromDate IS NULL OR c.date >= :fromDate)
      AND (:toDate IS NULL OR c.date <= :toDate)
    GROUP BY c.customerId
""")
    List<CustomerAmountView> getCustomerCreditAnalytics(
            @Param("customerIds") List<Integer> customerIds,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate
    );
}
