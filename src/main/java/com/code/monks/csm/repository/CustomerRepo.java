package com.code.monks.csm.repository;

import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.entity.CustomerEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerRepo extends JpaRepository<CustomerEntity, Integer> {

    @Query(value = "SELECT MAX(CAST(SUBSTRING(code, 2, 3) AS UNSIGNED)) FROM customer", nativeQuery = true)
    Integer findMaxCodeSuffix();

    CustomerEntity findByCustomerName(String customerName);

    Optional<CustomerEntity> findOneByCode(String code);

    boolean existsByGstNo(String gstNo);

    boolean existsByCode(String code);

    Page<CustomerEntity> findAllByStatus(Pageable pageable, StatusEnum status);

    List<CustomerEntity> findByCustomerNameContainingIgnoreCaseAndStatus(String keyword, StatusEnum status);
}
