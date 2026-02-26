package com.code.monks.csm.repository;

import com.code.monks.csm.entity.BillEntryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface BillEntryRepo extends JpaRepository<BillEntryEntity,Integer>,
        JpaSpecificationExecutor<BillEntryEntity>
{
    boolean existsByBillNumber(String billNumber);
    Optional<BillEntryEntity> findByBillNumber(String billNumber);
    Optional<BillEntryEntity> findTopByOrderByIdDesc();
    boolean existsByLrNumber(String lrNumber);
}
