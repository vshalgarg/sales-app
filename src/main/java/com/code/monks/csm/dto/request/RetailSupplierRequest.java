package com.code.monks.csm.dto.request;

public record RetailSupplierRequest(
        Integer supplierId,
        Long totalAmount,
        Long depositAmount,
        Long balanceAmount
) {
}
