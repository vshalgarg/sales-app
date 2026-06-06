package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotNull;

import java.time.LocalDate;

public record AddRetailSupplierRequestDto(

        @NotNull(message = "Retail Id is required")
        Long retailId,

        @NotNull(message = "Supplier Id is required")
        Integer supplierId,

        Long totalAmount,
        Long depositAmount,
        LocalDate depositDate

) {
}
