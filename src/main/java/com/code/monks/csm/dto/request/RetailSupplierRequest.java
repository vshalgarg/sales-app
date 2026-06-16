package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotNull;

public record RetailSupplierRequest(

        @NotNull(message = "Supplier is required")
        Integer supplierId,

        @NotNull(message = "Total Amount is required")
        Long totalAmount,
        Long depositAmount,
        Long balanceAmount
) {
}
