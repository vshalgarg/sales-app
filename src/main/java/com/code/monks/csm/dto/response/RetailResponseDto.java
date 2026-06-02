package com.code.monks.csm.dto.response;

import java.util.List;

public record RetailResponseDto(
        Integer id,
        String name,
        Integer customerId,
        String customerName,
        Integer staffId,
        String staffName,
        List<RetailSupplierResponseDto> suppliers
) {
}
