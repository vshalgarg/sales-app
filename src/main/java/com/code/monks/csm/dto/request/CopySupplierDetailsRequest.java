package com.code.monks.csm.dto.request;

import java.time.LocalDate;

public record CopySupplierDetailsRequest(
        LocalDate fromDate,
        LocalDate toDate,
        Integer supplierId,
        Integer customerId,
        Integer staffId
) {
}
