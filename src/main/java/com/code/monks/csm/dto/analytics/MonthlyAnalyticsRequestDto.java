package com.code.monks.csm.dto.analytics;

import java.time.LocalDate;
import java.util.List;

public record MonthlyAnalyticsRequestDto(
        List<Integer> supplierIds,
        List<Integer> customerIds,
        LocalDate fromDate,
        LocalDate toDate
) {
}