package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.List;

public record CreateRetailerRequestDto(
        @NotBlank(message = "Retail name is required")
        @Size(max = 255, message = "Retail name cannot exceed 255 characters")
        String name,

        @NotNull(message = "Date is required")
        LocalDate date,

        @NotNull(message = "Customer is required")
        Integer referredByCustomerId,
        Integer staffId,
        List<RetailSupplierRequest> suppliers,
        String commission
) {
}
