package com.code.monks.csm.service;

import com.code.monks.csm.dto.analytics.*;

import java.util.List;

public interface AnalyticsService {

    MonthlyAnalyticsResponseDto getMonthlyAnalytics(MonthlyAnalyticsRequestDto request);
    List<PieChartDataDto> getPieChartData(PieChartRequestDto request);
}
