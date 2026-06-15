package com.code.monks.csm.service;

import com.code.monks.csm.dto.analytics.MonthlyAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.MonthlyAnalyticsResponseDto;
import com.code.monks.csm.dto.analytics.StaffAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.StaffAnalyticsResponseDto;

public interface AnalyticsService {

    MonthlyAnalyticsResponseDto getMonthlyAnalytics(MonthlyAnalyticsRequestDto request);

    StaffAnalyticsResponseDto getStaffAnalytics(StaffAnalyticsRequestDto request);
}
