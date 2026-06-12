package com.code.monks.csm.repository;

import com.code.monks.csm.entity.BillEntryEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BillEntryRepo extends JpaRepository<BillEntryEntity,Integer>,
        JpaSpecificationExecutor<BillEntryEntity>
{
    Optional<BillEntryEntity> findByBillNumber(String billNumber);
    Optional<BillEntryEntity> findTopByOrderByIdDesc();

    @EntityGraph(attributePaths = {"supplier", "customer"})
    Page<BillEntryEntity> findAll(Specification<BillEntryEntity> spec, Pageable pageable);

    @Query("""
        SELECT b FROM BillEntryEntity b
        LEFT JOIN FETCH b.supplier
        LEFT JOIN FETCH b.customer
        LEFT JOIN FETCH b.transportEntity
        LEFT JOIN FETCH b.billDetails
        LEFT JOIN FETCH b.images
        WHERE b.id = :id
    """)
    Optional<BillEntryEntity> findDetailById(@Param("id") Integer id);

    List<BillEntryEntity> findBySupplier_IdAndCustomer_Id(
            Integer supplierId,
            Integer customerId
    );
}
