package com.code.monks.csm.repository;

import com.code.monks.csm.entity.BillEntryEntity;
import com.code.monks.csm.entity.CustomerEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.Optional;

@Repository
public interface BillEntryRepo extends JpaRepository<BillEntryEntity,Integer> {
    boolean existsByBillNumber(String billNumber);
    Optional<BillEntryEntity> findByBillNumber(String billNumber);
    Page<BillEntryEntity> findByDateBetweenAndSupplierIdEqualsAndCustomerIdEquals(
            LocalDate fromDate, LocalDate toDate, Integer supplierId, Integer customerId, Pageable pageable);

    Page<BillEntryEntity> findByDateBetweenAndSupplierIdEquals(
            LocalDate fromDate, LocalDate toDate, Integer supplierId, Pageable pageable);

    Page<BillEntryEntity> findByDateBetweenAndCustomerIdEquals(
            LocalDate fromDate, LocalDate toDate, Integer customerId, Pageable pageable);

    Page<BillEntryEntity> findByDateBetween(
            LocalDate fromDate, LocalDate toDate, Pageable pageable);

    Optional<BillEntryEntity> findTopByOrderByIdDesc();

    boolean existsByLrNumber(String lrNumber);

}
