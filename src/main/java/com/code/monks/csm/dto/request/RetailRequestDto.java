package com.code.monks.csm.dto.request;

import java.util.List;

public record RetailRequestDto(
        String name,
        Integer customerId,
        Integer staffId,
        List<RetailSupplierRequest> suppliers
) {
}
