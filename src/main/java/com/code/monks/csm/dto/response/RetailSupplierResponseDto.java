package com.code.monks.csm.dto.response;

public record RetailSupplierResponseDto(
        Integer supplierId,
        String supplierName,
        Long amount
) {
}
