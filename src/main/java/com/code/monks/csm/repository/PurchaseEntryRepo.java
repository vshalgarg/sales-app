package com.code.monks.csm.repository;

import com.code.monks.csm.entity.PurchaseEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;

public interface PurchaseEntryRepo extends
        JpaRepository<PurchaseEntity, Integer>,
        JpaSpecificationExecutor<PurchaseEntity> {
}
