package com.code.monks.csm.dto.analytics;

import lombok.Builder;

@Builder
public record SupplierAmountAnalyticsResponseDto(
        ChartDataDto supplierVsAmount
) {
}
