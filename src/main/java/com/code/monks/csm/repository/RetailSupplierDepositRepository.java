package com.code.monks.csm.repository;

import com.code.monks.csm.entity.RetailSupplierDepositEntity;
import com.code.monks.csm.enums.StatusEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface RetailSupplierDepositRepository extends JpaRepository<RetailSupplierDepositEntity, Integer> {

    @Query("""
    select d
    from RetailSupplierDepositEntity d
    where d.retailSupplier.id in :ids
    and d.status = :status
""")
    List<RetailSupplierDepositEntity> findByRetailSupplierIdsAndStatus(
            List<Integer> ids,
            StatusEnum status
    );

    @Modifying
    @Query("""
    update RetailSupplierDepositEntity d
    set d.status = :status
    where d.retailSupplier.retail.id = :retailId
""")
    int updateDepositStatus(
            Long retailId,
            StatusEnum status
    );
}
