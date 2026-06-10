package com.code.monks.csm.service;

import com.code.monks.csm.dto.analytics.AmountVsMonthDto;
import com.code.monks.csm.dto.analytics.AmountVsMonthRequestDto;
import com.code.monks.csm.dto.analytics.EntryCountDto;
import com.code.monks.csm.dto.analytics.PieChartDataDto;
import com.code.monks.csm.dto.analytics.PieChartRequestDto;

import java.util.List;

public interface AnalyticsService {

    List<AmountVsMonthDto> getAmountVsMonth(AmountVsMonthRequestDto request);

    List<EntryCountDto> getEntryCount(AmountVsMonthRequestDto request);

    List<PieChartDataDto> getPieChartData(PieChartRequestDto request);
}
