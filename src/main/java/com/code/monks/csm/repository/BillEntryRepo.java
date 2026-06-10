package com.code.monks.csm.repository;

import com.code.monks.csm.dto.analytics.projection.MonthlyAnalyticsView;
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
    boolean existsByBillNumber(String billNumber);
    Optional<BillEntryEntity> findByBillNumber(String billNumber);
    Optional<BillEntryEntity> findTopByOrderByIdDesc();
    boolean existsByLrNumber(String lrNumber);

    @EntityGraph(attributePaths = {"supplier", "customer"})
    Page<BillEntryEntity> findAll(Specification<BillEntryEntity> spec, Pageable pageable);

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
        AND (:fromDate IS NULL OR b.date >= :fromDate)
        AND (:toDate IS NULL OR b.date <= :toDate)
    GROUP BY YEAR(b.date), MONTH(b.date)
    ORDER BY YEAR(b.date), MONTH(b.date)
""")
    List<MonthlyAnalyticsView> getMonthlyBillAnalytics(
            @Param("supplierIds") List<Integer> supplierIds,
            @Param("customerIds") List<Integer> customerIds,
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate
    );

}
