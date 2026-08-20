package com.code.monks.csm.repository;

import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.enums.StatusEnum;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CustomerRepo extends JpaRepository<CustomerEntity, Integer> {

    @Query(value = "SELECT MAX(CAST(SUBSTRING(code, 2) AS UNSIGNED)) FROM customer", nativeQuery = true)
    Integer findMaxCodeSuffix();

    @EntityGraph(attributePaths = {"bankDetails"})
    Optional<CustomerEntity> findOneByCode(String code);

    boolean existsByCode(String code);

    Page<CustomerEntity> findAllByStatus(Pageable pageable, StatusEnum status);

    @EntityGraph(attributePaths = {"contactList"})
    @Query(
            value = """
        SELECT DISTINCT c FROM CustomerEntity c
        LEFT JOIN c.contactList con
        WHERE c.status = com.code.monks.csm.enums.StatusEnum.ACTIVE AND (
            LOWER(c.customerName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(c.gstNo) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(con.mobileNumber) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(c.city) LIKE LOWER(CONCAT('%', :keyword, '%'))
        )
        """,
            countQuery = """
        SELECT COUNT(DISTINCT c.id) FROM CustomerEntity c
        LEFT JOIN c.contactList con
        WHERE c.status = com.code.monks.csm.enums.StatusEnum.ACTIVE AND (
            LOWER(c.customerName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(c.gstNo) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(con.mobileNumber) LIKE LOWER(CONCAT('%', :keyword, '%')) OR
            LOWER(c.city) LIKE LOWER(CONCAT('%', :keyword, '%'))
        )
        """
    )
    Page<CustomerEntity> searchByKeyword(@Param("keyword") String keyword, Pageable pageable);
    List<CustomerEntity> findByStatus(StatusEnum statusEnum, Sort sort);
}
