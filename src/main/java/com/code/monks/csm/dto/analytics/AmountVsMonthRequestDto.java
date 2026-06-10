package com.code.monks.csm.dto.analytics;

import java.util.List;

public record AmountVsMonthRequestDto(
        List<Integer> supplierIds,
        List<Integer> customerIds
) {
}
