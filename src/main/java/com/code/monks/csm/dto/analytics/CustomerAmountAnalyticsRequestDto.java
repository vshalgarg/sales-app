package com.code.monks.csm.dto.analytics;

import java.time.LocalDate;
import java.util.List;

public record CustomerAmountAnalyticsRequestDto(
        List<Integer> customerIds,
        LocalDate fromDate,
        LocalDate toDate
) {
}
