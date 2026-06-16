package com.code.monks.csm.dto.response;

public record RetailSupplierResponseDto(

        Integer retailSupplierId,
        Integer supplierId,
        String supplierName,
        String supplierCity,
        Long totalAmount,
        Long depositAmount,
        Long balanceAmount
) {
}
