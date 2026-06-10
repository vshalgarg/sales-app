package com.code.monks.csm.dto.analytics.projection;

public record MonthlyAmountView(
        Integer year,
        Integer month,
        Long amount
) {
}
