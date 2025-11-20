package com.code.monks.csm.repository;

import com.code.monks.csm.entity.CreditEntryEntity;
import com.code.monks.csm.entity.PurchaseEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;

@Repository
public interface PurchaseEntryRepo extends JpaRepository<PurchaseEntity, Integer> {
    Page<PurchaseEntity> findByDateBetweenAndSupplierIdEqualsAndCustomerIdEquals(
            LocalDate fromDate,
            LocalDate toDate,
            int supplierId,
            int customerId,
            Pageable pageable
    );

    // ✅ Case 2: Filter by date + supplier
    Page<PurchaseEntity> findByDateBetweenAndSupplierIdEquals(
            LocalDate fromDate,
            LocalDate toDate,
            int supplierId,
            Pageable pageable
    );

    // ✅ Case 3: Filter by date + customer
    Page<PurchaseEntity> findByDateBetweenAndCustomerIdEquals(
            LocalDate fromDate,
            LocalDate toDate,
            int customerId,
            Pageable pageable
    );

    // ✅ Case 4: Filter only by date
    Page<PurchaseEntity> findByDateBetween(
            LocalDate fromDate,
            LocalDate toDate,
            Pageable pageable
    );
}
