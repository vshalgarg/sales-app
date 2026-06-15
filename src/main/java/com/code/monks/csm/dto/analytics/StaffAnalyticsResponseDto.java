package com.code.monks.csm.dto.analytics;

import lombok.Builder;

@Builder
public record StaffAnalyticsResponseDto(
        ChartDataDto supplierVsStaff,
        ChartDataDto customerVsStaff,
        ChartDataDto supplierAndCustomerVsStaff
) {
}
