package com.code.monks.csm.dto.analytics;

import com.code.monks.csm.enums.DataTypeEnum;

import java.time.LocalDate;

public record PieChartRequestDto(
        DataTypeEnum dataType,
        LocalDate fromDate,
        LocalDate toDate
) {
}
