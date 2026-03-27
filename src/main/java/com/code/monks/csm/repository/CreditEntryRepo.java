package com.code.monks.csm.repository;

import com.code.monks.csm.entity.CreditEntryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

@Repository
public interface CreditEntryRepo extends JpaRepository<CreditEntryEntity,Integer>,
        JpaSpecificationExecutor<CreditEntryEntity> {

    boolean existsByReferenceNumber(String referenceNumber);
}
