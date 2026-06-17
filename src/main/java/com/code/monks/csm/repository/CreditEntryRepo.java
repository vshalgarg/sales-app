package com.code.monks.csm.repository;

import com.code.monks.csm.entity.CreditEntryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CreditEntryRepo extends JpaRepository<CreditEntryEntity,Integer>,
        JpaSpecificationExecutor<CreditEntryEntity> {

    boolean existsByReferenceNumber(String referenceNumber);

    List<CreditEntryEntity> findBySupplierIdAndCustomerId(
            Integer supplierId,
            Integer customerId
    );
}
