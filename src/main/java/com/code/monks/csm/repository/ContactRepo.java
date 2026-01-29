package com.code.monks.csm.repository;

import com.code.monks.csm.entity.ContactEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ContactRepo extends JpaRepository<ContactEntity,Integer> {
    boolean existsByMobileNumber(String mobileNumber);
}
