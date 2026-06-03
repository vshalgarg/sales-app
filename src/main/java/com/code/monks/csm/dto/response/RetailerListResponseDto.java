package com.code.monks.csm.dto.response;

import java.time.LocalDate;

public record RetailerListResponseDto(

        Integer retailId,
        String retailName,
        String customerName,
        String staffName,
        String supplierName,
        LocalDate transactionDate,
        Long totalAmount,
        Long depositAmount,
        Long balanceAmount
) {
}
