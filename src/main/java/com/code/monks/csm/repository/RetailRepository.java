package com.code.monks.csm.repository;

import com.code.monks.csm.entity.RetailerEntity;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RetailRepository extends JpaRepository<RetailerEntity,Long> {

    @EntityGraph(attributePaths = {
            "customer",
            "staff",
            "suppliers",
            "suppliers.supplier"
    })
    Optional<RetailerEntity> findRetailDetailsById(Long id);
}
