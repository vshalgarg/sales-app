package com.code.monks.csm.dto.request;

import java.util.List;

public record RetailRequestDto(
        String name,
        Integer customerId,
        Integer staffId,
        Long depositAmount,
        Long balanceAmount,
        List<RetailSupplierRequest> suppliers
) {
}
