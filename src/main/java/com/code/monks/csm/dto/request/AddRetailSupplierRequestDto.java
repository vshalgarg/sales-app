package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;

public record AddRetailSupplierRequestDto(

        @NotNull(message = "Retail Id is required")
        Long retailId,

        @NotNull(message = "Supplier Id is required")
        Integer supplierId,

        @NotNull(message = "Total Amount is required")
        @Positive(message = "Total Amount must be greater than zero")
        Long totalAmount,

        Long depositAmount,

        LocalDate depositDate

) {
}
