package com.code.monks.csm.repository;

import com.code.monks.csm.entity.StaffEntity;
import com.code.monks.csm.enums.StatusEnum;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface StaffRepo extends JpaRepository<StaffEntity,Integer> {
    Page<StaffEntity> findAllByStatus(Pageable pageable, StatusEnum status);
    List<StaffEntity> findAllByStatus(Sort sort, StatusEnum status);
    boolean existsByPhone(String phone);
    Page<StaffEntity> findByStaffNameContainingIgnoreCaseAndStatus(String keyword, StatusEnum statusEnum, Pageable pageable);

    @Query("""
    SELECT COUNT(s)
    FROM StaffEntity s
    WHERE s.status = com.code.monks.csm.enums.StatusEnum.ACTIVE
    AND s.joiningDate BETWEEN :from AND :to
""")
    long countActiveStaffBetween(
            @Param("from") LocalDate from,
            @Param("to") LocalDate to
    );

    @Query("""
    SELECT COUNT(s)
    FROM StaffEntity s
    WHERE s.status = com.code.monks.csm.enums.StatusEnum.ACTIVE
""")
    long countActiveStaff();
}
