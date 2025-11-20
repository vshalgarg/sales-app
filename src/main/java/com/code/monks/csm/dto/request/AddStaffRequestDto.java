package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class AddStaffRequestDto {
    @NotBlank(message = "Staff name must not be blank.")
    private String staffName;

    @NotBlank(message = "Phone must not be blank.")
    private String phone;

    @NotNull(message = "Joining date must not be null.")
    private LocalDate joiningDate;
}
