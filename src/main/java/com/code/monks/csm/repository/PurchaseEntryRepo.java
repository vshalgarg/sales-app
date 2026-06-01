package com.code.monks.csm.repository;

import com.code.monks.csm.entity.PurchaseEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;

public interface PurchaseEntryRepo extends
        JpaRepository<PurchaseEntity, Integer>,
        JpaSpecificationExecutor<PurchaseEntity> {

    @EntityGraph(attributePaths = {
            "supplier",
            "customer"
    })
    Page<PurchaseEntity> findAll(Specification<PurchaseEntity> spec, Pageable pageable);

    @EntityGraph(attributePaths = {"supplier"})
    List<PurchaseEntity> findAll(
            Specification<PurchaseEntity> specification
    );
}
