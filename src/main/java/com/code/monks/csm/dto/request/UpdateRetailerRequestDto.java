package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;

public record UpdateRetailerRequestDto (

        @NotBlank(message = "Retail name is required")
        @Size(max = 255, message = "Retail name cannot exceed 255 characters")
        String name,

        @NotNull(message = "Date is required")
        LocalDate date,

        Integer referredByCustomerId,

        Integer staffId
){
}
