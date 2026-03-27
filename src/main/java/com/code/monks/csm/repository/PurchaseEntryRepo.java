package com.code.monks.csm.repository;

import com.code.monks.csm.entity.PurchaseEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

public interface PurchaseEntryRepo extends
        JpaRepository<PurchaseEntity, Integer>,
        JpaSpecificationExecutor<PurchaseEntity> {
}
