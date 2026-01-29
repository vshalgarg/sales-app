package com.code.monks.csm.repository;

import com.code.monks.csm.entity.PurchaseEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;

@Repository
public interface PurchaseEntryRepo extends JpaRepository<PurchaseEntity, Integer> {


    Page<PurchaseEntity> findByDateBetweenAndSupplierId(LocalDate fromDate, LocalDate toDate, Integer supplierId, Pageable pageable);
    Page<PurchaseEntity> findBySupplierId(Integer supplierId, Pageable pageable);

    Page<PurchaseEntity> findByDateBetween(LocalDate fromDate, LocalDate toDate, Pageable pageable);

    Page<PurchaseEntity> findByDateBetweenAndSupplierIdAndCustomers_Id(LocalDate fromDate, LocalDate toDate, Integer supplierId, Integer customerId, Pageable pageable);

    Page<PurchaseEntity> findByDateBetweenAndCustomers_Id(LocalDate fromDate, LocalDate toDate, Integer customerId, Pageable pageable);

    Page<PurchaseEntity> findBySupplierIdAndCustomers_Id(Integer supplierId, Integer customerId, Pageable pageable);

    Page<PurchaseEntity> findByCustomers_Id(Integer customerId, Pageable pageable);
}
