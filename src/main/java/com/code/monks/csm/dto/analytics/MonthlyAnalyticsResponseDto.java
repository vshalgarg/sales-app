package com.code.monks.csm.dto.analytics;

import lombok.Builder;

import java.util.List;

@Builder
public record MonthlyAnalyticsResponseDto(
        List<MonthlyAnalyticsDto> records
) {
}
