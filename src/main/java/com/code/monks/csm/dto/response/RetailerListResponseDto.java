package com.code.monks.csm.dto.response;

import java.time.LocalDate;
import java.util.List;

public record RetailerListResponseDto(

        Integer retailId,
        String retailName,
        String referredByCustomerName,
        String staffName,
        LocalDate date,
        List<RetailSupplierResponseDto> suppliers
) {
}
