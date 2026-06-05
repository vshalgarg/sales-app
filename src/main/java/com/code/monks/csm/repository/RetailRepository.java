package com.code.monks.csm.repository;

import com.code.monks.csm.entity.RetailSupplierEntity;
import com.code.monks.csm.entity.RetailerEntity;
import com.code.monks.csm.enums.StatusEnum;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.*;

import java.util.Optional;

public interface RetailRepository extends JpaRepository<RetailerEntity,Long>,
        JpaSpecificationExecutor<RetailerEntity> {

    @Query("""
    select distinct r
    from RetailerEntity r
    left join fetch r.customer
    left join fetch r.staff
    left join fetch r.suppliers rs
    left join fetch rs.supplier
    where r.id = :id
      and r.status = :status
      and rs.status = com.code.monks.csm.enums.StatusEnum.ACTIVE
""")
    Optional<RetailerEntity> findByIdAndStatusWithActiveSuppliers(
            Long id,
            StatusEnum status
    );

    @EntityGraph(attributePaths = {
            "customer",
            "staff",
            "suppliers",
            "suppliers.supplier"
    })
    Optional<RetailerEntity> findByIdAndStatus(
            Long id,
            StatusEnum status
    );

    @EntityGraph(attributePaths = {
            "customer",
            "staff",
            "suppliers",
            "suppliers.supplier"
    })
    Page<RetailerEntity> findAll(
            Specification<RetailerEntity> spec,
            Pageable pageable
    );


    @Query("""
    select distinct r
    from RetailerEntity r
    left join fetch r.suppliers rs
    left join fetch rs.supplier
    where r.id = :id
""")
    Optional<RetailerEntity> findByIdWithSuppliers(Long id);

    @Modifying
    @Query("""
    update RetailerEntity r
    set r.status = :status
    where r.id = :retailId
""")
    int updateRetailStatus(
            Long retailId,
            StatusEnum status
    );
}
