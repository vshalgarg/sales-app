package com.code.monks.csm.repository;

import com.code.monks.csm.entity.PurchaseEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;

@Repository
public interface PurchaseEntryRepo extends JpaRepository<PurchaseEntity, Integer> {


    Page<PurchaseEntity> findByDateBetweenAndSuppliers_Id(LocalDate from, LocalDate to, Integer supplierId, Pageable pageable);
    Page<PurchaseEntity> findBySuppliers_Id(Integer supplierId, Pageable pageable);

    Page<PurchaseEntity> findByDateBetween(LocalDate fromDate, LocalDate toDate, Pageable pageable);

    Page<PurchaseEntity> findByDateBetweenAndSuppliers_IdAndCustomer_Id(LocalDate fromDate, LocalDate toDate, Integer supplierId, Integer customerId, Pageable pageable);

    Page<PurchaseEntity> findByDateBetweenAndCustomer_Id(LocalDate fromDate, LocalDate toDate, Integer customerId, Pageable pageable);
    Page<PurchaseEntity> findBySuppliers_IdAndCustomer_Id(Integer supplierId, Integer customerId, Pageable pageable);

    Page<PurchaseEntity> findByCustomer_Id(Integer customerId, Pageable pageable);

}
