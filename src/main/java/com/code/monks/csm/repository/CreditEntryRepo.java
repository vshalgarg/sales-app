package com.code.monks.csm.repository;

import com.code.monks.csm.entity.CreditEntryEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface CreditEntryRepo extends JpaRepository<CreditEntryEntity,Integer> {

    boolean existsByReferenceNumber(String referenceNumber);

    Page<CreditEntryEntity> findByDateBetweenAndSupplierIdEqualsAndCustomerIdEquals(
            LocalDate fromDate,
            LocalDate toDate,
            int supplierId,
            int customerId,
            Pageable pageable
    );
    

    // ✅ Case 4: Filter only by date
    Page<CreditEntryEntity> findByDateBetween(
            LocalDate fromDate,
            LocalDate toDate,
            Pageable pageable
    );

    Page<CreditEntryEntity> findByDateBetweenAndSupplierIdAndCustomerId(LocalDate startDate, LocalDate endDate, Integer supplierId, Integer customerId, Pageable pageable);

    Page<CreditEntryEntity> findByDateBetweenAndSupplierId(LocalDate startDate, LocalDate endDate, Integer supplierId, Pageable pageable);

    Page<CreditEntryEntity> findByDateBetweenAndCustomerId(LocalDate startDate, LocalDate endDate, Integer customerId, Pageable pageable);

    Optional<CreditEntryEntity> findByBillNumber(String billNumber);
}
