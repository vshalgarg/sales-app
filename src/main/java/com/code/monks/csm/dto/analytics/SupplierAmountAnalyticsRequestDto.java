package com.code.monks.csm.dto.analytics;

import java.time.LocalDate;
import java.util.List;

public record SupplierAmountAnalyticsRequestDto(
        List<Integer> supplierIds,
        LocalDate fromDate,
        LocalDate toDate
) {
}
