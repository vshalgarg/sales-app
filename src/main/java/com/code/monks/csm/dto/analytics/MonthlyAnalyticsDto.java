package com.code.monks.csm.dto.analytics;

import java.math.BigDecimal;

public record MonthlyAnalyticsDto(
        String month,
        BigDecimal billAmount,
        BigDecimal creditAmount,
        Long billCount,
        Long creditCount
) {
}