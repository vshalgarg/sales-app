package com.code.monks.csm.dto.analytics;

public record MonthlyAnalyticsDto(
        String month,
        Double billAmount,
        Double creditAmount,
        Long billCount,
        Long creditCount
) {
}
