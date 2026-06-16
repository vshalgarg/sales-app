package com.code.monks.csm.service;

import com.code.monks.csm.dto.analytics.MonthlyAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.MonthlyAnalyticsResponseDto;
import com.code.monks.csm.dto.analytics.StaffAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.StaffAnalyticsResponseDto;
import com.code.monks.csm.dto.analytics.CustomerAmountAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.CustomerAmountAnalyticsResponseDto;
import com.code.monks.csm.dto.analytics.SupplierAmountAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.SupplierAmountAnalyticsResponseDto;

public interface AnalyticsService {

    MonthlyAnalyticsResponseDto getMonthlyAnalytics(MonthlyAnalyticsRequestDto request);

    StaffAnalyticsResponseDto getStaffAnalytics(StaffAnalyticsRequestDto request);

    SupplierAmountAnalyticsResponseDto getSupplierAmountAnalytics(SupplierAmountAnalyticsRequestDto request);

    CustomerAmountAnalyticsResponseDto getCustomerAmountAnalytics(CustomerAmountAnalyticsRequestDto request);
}
