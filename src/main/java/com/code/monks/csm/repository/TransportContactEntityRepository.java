package com.code.monks.csm.repository;

import com.code.monks.csm.entity.TransportContactEntity;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TransportContactEntityRepository extends JpaRepository<TransportContactEntity, Integer> {
}