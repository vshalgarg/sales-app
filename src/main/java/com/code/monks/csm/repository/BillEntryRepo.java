package com.code.monks.csm.repository;

import com.code.monks.csm.dto.analytics.projection.MonthlyAnalyticsView;
import com.code.monks.csm.dto.analytics.projection.CustomerAmountView;
import com.code.monks.csm.dto.analytics.projection.SupplierAmountView;
import com.code.monks.csm.entity.BillEntryEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface BillEntryRepo extends JpaRepository<BillEntryEntity,Integer>,
        JpaSpecificationExecutor<BillEntryEntity>
{
    Optional<BillEntryEntity> findByBillNumber(String billNumber);
    Optional<BillEntryEntity> findTopByOrderByIdDesc();

    @EntityGraph(attributePaths = {"supplier", "customer"})
    Page<BillEntryEntity> findAll(Specification<BillEntryEntity> spec, Pageable pageable);

    @Query("""
        SELECT b FROM BillEntryEntity b
        LEFT JOIN FETCH b.supplier
        LEFT JOIN FETCH b.customer
        LEFT JOIN FETCH b.transportEntity
        LEFT JOIN FETCH b.billDetails
        LEFT JOIN FETCH b.images
        WHERE b.id = :id
    """)
    Optional<BillEntryEntity> findDetailById(@Param("id") Integer id);

    List<BillEntryEntity> findBySupplier_IdAndCustomer_Id(
            Integer supplierId,
            Integer customerId
    );

    @Query("""
    SELECT
        YEAR(b.date) as year,
        MONTH(b.date) as month,
        COALESCE(SUM(b.billAmount), 0) as amount,
        COALESCE(COUNT(b.id), 0) as count
    FROM BillEntryEntity b
    WHERE
        b.date IS NOT NULL
        AND (:supplierIds IS NULL OR b.supplier.id IN :supplierIds)
        AND (:customerIds IS NULL OR b.customer.id IN :customerIds)
        AND b.date BETWEEN :fromDate AND :toDate
    GROUP BY YEAR(b.date), MONTH(b.date)
    ORDER BY YEAR(b.date), MONTH(b.date)
""")
    List<MonthlyAnalyticsView> getMonthlyBillAnalytics(
            @Param("supplierIds") List<Integer> supplierIds,
            @Param("customerIds") List<Integer> customerIds,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate
    );

    @Query("""
    SELECT b.supplier.id as supplierId,
    COALESCE(SUM(b.billAmount), 0) as amount
    FROM BillEntryEntity b
    WHERE (:supplierIds IS NULL OR b.supplier.id IN :supplierIds)
    AND b.date BETWEEN :fromDate AND :toDate
    GROUP BY b.supplier.id
    ORDER BY COALESCE(SUM(b.billAmount), 0) DESC
""")
    List<SupplierAmountView> getSupplierBillAnalytics(
            @Param("supplierIds") List<Integer> supplierIds,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate
    );

    @Query("""
    SELECT b.customer.id as customerId,
    COALESCE(SUM(b.billAmount), 0) as amount
    FROM BillEntryEntity b
    WHERE (:customerIds IS NULL OR b.customer.id IN :customerIds)
    AND b.date BETWEEN :fromDate AND :toDate
    GROUP BY b.customer.id
    ORDER BY COALESCE(SUM(b.billAmount), 0) DESC
""")
    List<CustomerAmountView> getCustomerBillAnalytics(
            @Param("customerIds") List<Integer> customerIds,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate
    );
}
