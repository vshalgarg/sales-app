package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalDate;

@Data
public class UpdateStaffRequestDto {

    @NotBlank(message = "Staff name is required")
    private String staffName;

    @NotBlank(message = "Phone is required")
    private String phone;

    private LocalDate joiningDate;
}
