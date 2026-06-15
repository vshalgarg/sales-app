package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.ApiResponse;
import com.code.monks.csm.dto.analytics.MonthlyAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.MonthlyAnalyticsResponseDto;
import com.code.monks.csm.dto.analytics.StaffAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.StaffAnalyticsResponseDto;
import com.code.monks.csm.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static com.code.monks.csm.constants.ApiPaths.ANALYTICS_MONTHLY;
import static com.code.monks.csm.constants.ApiPaths.ANALYTICS_STAFF;
import static com.code.monks.csm.constants.ApiPaths.BASE;

@RestController
@RequestMapping(BASE)
@RequiredArgsConstructor
@Slf4j
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @PostMapping(ANALYTICS_MONTHLY)
    public ResponseEntity<ApiResponse<MonthlyAnalyticsResponseDto>> getMonthlyAnalytics(@RequestBody MonthlyAnalyticsRequestDto request) {
        log.info("Fetching monthly analytics");
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Monthly analytics fetched successfully",
                        analyticsService.getMonthlyAnalytics(request)
                )
        );
    }

    @PostMapping(ANALYTICS_STAFF)
    public ResponseEntity<ApiResponse<StaffAnalyticsResponseDto>> getStaffAnalytics(@RequestBody StaffAnalyticsRequestDto request) {
        log.info("Fetching staff analytics");
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Staff analytics fetched successfully",
                        analyticsService.getStaffAnalytics(request)
                )
        );
    }
}
