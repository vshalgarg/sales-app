package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.analytics.DatasetDto;
import com.code.monks.csm.dto.analytics.MonthlyAnalyticsDto;
import com.code.monks.csm.dto.analytics.MonthlyAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.MonthlyAnalyticsResponseDto;
import com.code.monks.csm.dto.analytics.projection.MonthlyAnalyticsView;
import com.code.monks.csm.repository.*;
import com.code.monks.csm.service.AnalyticsService;
import com.code.monks.csm.utils.MoneyUtil;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.TextStyle;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TreeMap;

@Service
@Slf4j
@RequiredArgsConstructor
public class AnalyticsServiceImpl implements AnalyticsService {

    private final BillEntryRepo billEntryRepo;
    private final CreditEntryRepo creditEntryRepo;
    private final CustomerRepo customerRepo;
    private final SupplierRepo supplierRepo;
    private final StaffRepo staffRepo;

    @Override
    public MonthlyAnalyticsResponseDto getMonthlyAnalytics(MonthlyAnalyticsRequestDto request) {

        log.info(
                "Fetching monthly analytics. SupplierIds: {}, CustomerIds: {}",
                request.supplierIds(),
                request.customerIds()
        );

        List<Integer> supplierIds = normalizeIds(request.supplierIds());
        List<Integer> customerIds = normalizeIds(request.customerIds());
        LocalDate fromDate = request.fromDate();
        LocalDate toDate = request.toDate();
        if (fromDate == null && toDate == null) {
            toDate = LocalDate.now();
            fromDate = toDate.minusMonths(11).withDayOfMonth(1);
        }

        List<MonthlyAnalyticsView> billAnalytics =
                billEntryRepo.getMonthlyBillAnalytics(
                        supplierIds,
                        customerIds,
                        fromDate,
                        toDate
                );

        List<MonthlyAnalyticsView> creditAnalytics =
                creditEntryRepo.getMonthlyCreditAnalytics(
                        supplierIds,
                        customerIds,
                        fromDate,
                        toDate
                );

        Map<YearMonth, MonthlyAnalyticsAccumulator> monthlyMap = new TreeMap<>();
        for (MonthlyAnalyticsView bill : billAnalytics) {
            YearMonth yearMonth = YearMonth.of(
                    bill.getYear(),
                    bill.getMonth()
            );

            MonthlyAnalyticsAccumulator data =
                    monthlyMap.computeIfAbsent(
                            yearMonth,
                            key -> new MonthlyAnalyticsAccumulator()
                    );

            data.setBillAmount(bill.getAmount());
            data.setBillCount(bill.getCount());
        }

        for (MonthlyAnalyticsView credit : creditAnalytics) {
            YearMonth yearMonth = YearMonth.of(
                    credit.getYear(),
                    credit.getMonth()
            );

            MonthlyAnalyticsAccumulator data =
                    monthlyMap.computeIfAbsent(
                            yearMonth,
                            key -> new MonthlyAnalyticsAccumulator()
                    );

            data.setCreditAmount(credit.getAmount());
            data.setCreditCount(credit.getCount());
        }

        YearMonth startMonth = YearMonth.from(fromDate);
        YearMonth endMonth = YearMonth.from(toDate);

        while (!startMonth.isAfter(endMonth)) {
            monthlyMap.putIfAbsent(
                    startMonth,
                    new MonthlyAnalyticsAccumulator()
            );
            startMonth = startMonth.plusMonths(1);
        }

        List<MonthlyAnalyticsDto> records =
                monthlyMap.entrySet()
                        .stream()
                        .map(entry -> {
                            YearMonth yearMonth = entry.getKey();
                            MonthlyAnalyticsAccumulator data = entry.getValue();
                            return new MonthlyAnalyticsDto(
                                    yearMonth.getMonth().getDisplayName(
                                            TextStyle.SHORT,
                                            Locale.ENGLISH
                                    ),
                                    MoneyUtil.toRupee(data.getBillAmount()),
                                    MoneyUtil.toRupee(data.getCreditAmount()),
                                    data.getBillCount(),
                                    data.getCreditCount()
                            );
                        })
                        .toList();

        List<String> labels =
                records.stream()
                        .map(MonthlyAnalyticsDto::month)
                        .toList();

        List<DatasetDto> datasets = List.of(

                DatasetDto.builder()
                        .label("Bill Amount")
                        .data(
                                records.stream()
                                        .map(MonthlyAnalyticsDto::billAmount)
                                        .toList()
                        )
                        .unit("₹")
                        .build(),

                DatasetDto.builder()
                        .label("Credit Amount")
                        .data(
                                records.stream()
                                        .map(MonthlyAnalyticsDto::creditAmount)
                                        .toList()
                        )
                        .unit("₹")
                        .build(),

                DatasetDto.builder()
                        .label("Bill Count")
                        .data(
                                records.stream()
                                        .map(MonthlyAnalyticsDto::billCount)
                                        .toList()
                        )
                        .unit("COUNT")
                        .build(),

                DatasetDto.builder()
                        .label("Credit Count")
                        .data(
                                records.stream()
                                        .map(MonthlyAnalyticsDto::creditCount)
                                        .toList()
                        )
                        .unit("COUNT")
                        .build()
        );

        return MonthlyAnalyticsResponseDto.builder()
                .labels(labels)
                .datasets(datasets)
                .build();
    }


    private List<Integer> normalizeIds(
            List<Integer> ids
    ) {
        return ids == null || ids.isEmpty()
                ? null
                : ids;
    }


    @Getter
    @Setter
    private static class MonthlyAnalyticsAccumulator {

        private Long billAmount;
        private Long creditAmount;
        private long billCount;
        private long creditCount;
    }
}