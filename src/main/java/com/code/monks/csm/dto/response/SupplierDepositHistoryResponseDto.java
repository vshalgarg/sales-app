package com.code.monks.csm.dto.response;

import lombok.Builder;

import java.util.List;

@Builder
public record SupplierDepositHistoryResponseDto(
        Integer retailSupplierId,
        Integer supplierId,
        String supplierName,
        String supplierCity,
        Long totalAmount,
        Long depositAmount,
        Long balanceAmount,

        List<DepositHistoryDto> deposits
) {
}
