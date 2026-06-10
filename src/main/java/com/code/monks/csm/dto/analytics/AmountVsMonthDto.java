package com.code.monks.csm.dto.analytics;

public record AmountVsMonthDto(
        String month,
        Long billAmount,
        Long creditAmount
) {
}
