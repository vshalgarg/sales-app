package com.code.monks.csm.repository;

import com.code.monks.csm.dto.analytics.projection.StaffAnalyticsView;
import com.code.monks.csm.entity.PurchaseEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

import java.util.List;

public interface PurchaseEntryRepo extends
        JpaRepository<PurchaseEntity, Integer>,
        JpaSpecificationExecutor<PurchaseEntity> {

    @EntityGraph(attributePaths = {
            "supplier",
            "customer"
    })
    Page<PurchaseEntity> findAll(Specification<PurchaseEntity> spec, Pageable pageable);

    @Query("""
    SELECT p.staffId as staffId, COUNT(DISTINCT p.supplier.id) as count
    FROM PurchaseEntity p
    WHERE (:fromDate IS NULL OR p.date >= :fromDate)
      AND (:toDate IS NULL OR p.date <= :toDate)
    GROUP BY p.staffId
""")
    List<StaffAnalyticsView> getStaffSupplierAnalytics(
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate
    );

    @Query("""
    SELECT p.staffId as staffId, COUNT(DISTINCT p.customer.id) as count
    FROM PurchaseEntity p
    WHERE (:fromDate IS NULL OR p.date >= :fromDate)
      AND (:toDate IS NULL OR p.date <= :toDate)
    GROUP BY p.staffId
""")
    List<StaffAnalyticsView> getStaffCustomerAnalytics(
            @Param("fromDate") LocalDate fromDate,
            @Param("toDate") LocalDate toDate
    );

    @EntityGraph(attributePaths = {"supplier"})
    List<PurchaseEntity> findAll(
            Specification<PurchaseEntity> specification
    );
}
