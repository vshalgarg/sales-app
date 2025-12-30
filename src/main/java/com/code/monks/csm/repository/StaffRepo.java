package com.code.monks.csm.repository;

import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.entity.StaffEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface StaffRepo extends JpaRepository<StaffEntity,Integer> {
    Page<StaffEntity> findAllByStatus(Pageable pageable, StatusEnum status);
    boolean existsByPhone(String phone);
    Page<StaffEntity> findByStaffNameContainingIgnoreCaseAndStatus(String keyword, StatusEnum statusEnum, Pageable pageable);

    Page<StaffEntity> findByStaffNameContainingIgnoreCase(String trimmedKeyword, Pageable pageable);
}
