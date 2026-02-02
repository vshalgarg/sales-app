package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.hibernate.annotations.processing.Pattern;

import java.time.LocalDate;

@Data
public class AddStaffRequestDto {
    @NotBlank(message = "Staff name is required")
    private String staffName;

    private String phone;

    @NotNull(message = "Joining date is required")
    private LocalDate joiningDate;
}
