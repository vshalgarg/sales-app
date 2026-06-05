package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.time.LocalDate;
import java.util.List;

public record RetailSupplierDepositRequestDto(

        @NotEmpty(message = "Deposits list cannot be empty")
        List<DepositDto> deposits

) {
        public record DepositDto(

                @NotNull(message = "Retail Supplier Id is required")
                Integer retailSupplierId,

                @NotNull(message = "Deposit Date is required")
                LocalDate depositDate,

                @NotNull(message = "Amount is required")
                @Positive(message = "Amount must be greater than zero")
                Long amount

        ) {
        }
}
