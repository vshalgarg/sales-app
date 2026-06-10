package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.ApiResponse;
import com.code.monks.csm.dto.analytics.*;
import com.code.monks.csm.enums.DataTypeEnum;
import com.code.monks.csm.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

import static com.code.monks.csm.constants.ApiPaths.AMOUNT_VS_MONTH;
import static com.code.monks.csm.constants.ApiPaths.BASE;
import static com.code.monks.csm.constants.ApiPaths.ENTRY_COUNT;
import static com.code.monks.csm.constants.ApiPaths.PIE_CHART;

@RestController
@RequestMapping(BASE)
@RequiredArgsConstructor
@Slf4j
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @PostMapping(AMOUNT_VS_MONTH)
    public ResponseEntity<ApiResponse<MonthlyAnalyticsResponseDto>> getAmountVsMonth(@RequestBody MonthlyAnalyticsRequestDto request) {
        log.info("Fetching amount vs month analytics");
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Amount vs month fetched successfully",
                        analyticsService.getMonthlyAnalytics(request)
                )
        );
    }

    @GetMapping(PIE_CHART)
    public ResponseEntity<ApiResponse<List<PieChartDataDto>>> getPieChartData(
            @RequestParam DataTypeEnum dataType,
            @RequestParam(required = false) LocalDate fromDate,
            @RequestParam(required = false) LocalDate toDate) {

        log.info("Fetching pie chart analytics for type: {}", dataType);

        PieChartRequestDto request = new PieChartRequestDto(
                dataType,
                fromDate,
                toDate
        );
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Pie chart analytics fetched successfully",
                        analyticsService.getPieChartData(request)
                )
        );
    }
}
