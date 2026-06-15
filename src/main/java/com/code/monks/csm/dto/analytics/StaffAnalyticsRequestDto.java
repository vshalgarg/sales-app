package com.code.monks.csm.dto.analytics;

import java.time.LocalDate;

public record StaffAnalyticsRequestDto(
        LocalDate fromDate,
        LocalDate toDate
) {
}
