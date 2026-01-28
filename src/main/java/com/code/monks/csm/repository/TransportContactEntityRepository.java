package com.code.monks.csm.repository;

import com.code.monks.csm.entity.TransportContactEntity;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TransportContactEntityRepository extends JpaRepository<TransportContactEntity, Integer> {
    boolean existsByContactNumber(@NotBlank(message = "Contact number is required") @Pattern(
            regexp = "\\d{10}",
            message = "Contact number must be exactly 10 digits"
    ) String contactNumber);

    boolean existsByContactNumberAndTransportIdNot(@NotBlank(message = "Contact number is required") @Pattern(
            regexp = "\\d{10}",
            message = "Contact number must be exactly 10 digits"
    ) String contactNumber, Integer excludeId);
}