package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotNull;

public record UpdateRetailSupplierRequestDto(

        @NotNull(message = "Total Amount is required")
        Long totalAmount
) {
}
