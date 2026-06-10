package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.analytics.*;
import com.code.monks.csm.dto.analytics.projection.CountView;
import com.code.monks.csm.dto.analytics.projection.MonthlyAmountView;
import com.code.monks.csm.dto.analytics.projection.MonthlyAnalyticsView;
import com.code.monks.csm.repository.BillEntryRepo;
import com.code.monks.csm.repository.CreditEntryRepo;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.StaffRepo;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.service.AnalyticsService;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.*;

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
                                    data.getBillAmount(),
                                    data.getCreditAmount(),
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
                .records(records)
                .build();
    }

    @Override
    public List<PieChartDataDto> getPieChartData(PieChartRequestDto request) {

        log.info(
                "Fetching pie chart data. Type: {}, From Date: {}, To Date: {}",
                request.dataType(),
                request.fromDate(),
                request.toDate()
        );

        LocalDate fromDate = request.fromDate() != null
                ? request.fromDate()
                : null;

        LocalDate toDate = request.toDate() != null
                ? request.toDate()
                : null;

        LocalDateTime fromDateTime =
                fromDate != null ? fromDate.atStartOfDay() : null;

        LocalDateTime toDateTime =
                toDate != null ? toDate.plusDays(1).atStartOfDay() : null;

        log.debug(
                "Resolved date filters. FromDateTime: {}, ToDateTime: {}",
                fromDateTime,
                toDateTime
        );

        return switch (request.dataType()) {

            case CUSTOMER_VS_STAFF -> {

                long customerCount =
                        fromDateTime == null || toDateTime == null
                                ? customerRepo.countActiveCustomers()
                                : customerRepo.countActiveCustomersBetween(fromDateTime, toDateTime);

                long staffCount =
                        fromDate == null || toDate == null
                                ? staffRepo.countActiveStaff()
                                : staffRepo.countActiveStaffBetween(fromDate, toDate);

                log.info(
                        "Customer vs Staff analytics generated. Customer Count: {}, Staff Count: {}",
                        customerCount,
                        staffCount
                );

                yield List.of(
                        new PieChartDataDto("Customer", customerCount),
                        new PieChartDataDto("Staff", staffCount)
                );
            }

            case SUPPLIER_VS_STAFF -> {

                long supplierCount =
                        fromDateTime == null || toDateTime == null
                                ? supplierRepo.countActiveSuppliers()
                                : supplierRepo.countActiveSuppliersBetween(fromDateTime, toDateTime);

                long staffCount =
                        fromDate == null || toDate == null
                                ? staffRepo.countActiveStaff()
                                : staffRepo.countActiveStaffBetween(fromDate, toDate);

                log.info(
                        "Supplier vs Staff analytics generated. Supplier Count: {}, Staff Count: {}",
                        supplierCount,
                        staffCount
                );

                yield List.of(
                        new PieChartDataDto("Supplier", supplierCount),
                        new PieChartDataDto("Staff", staffCount)
                );
            }

            case SUPPLIER_CUSTOMER_VS_STAFF -> {

                long customerCount =
                        fromDateTime == null || toDateTime == null
                                ? customerRepo.countActiveCustomers()
                                : customerRepo.countActiveCustomersBetween(fromDateTime, toDateTime);

                long supplierCount =
                        fromDateTime == null || toDateTime == null
                                ? supplierRepo.countActiveSuppliers()
                                : supplierRepo.countActiveSuppliersBetween(fromDateTime, toDateTime);

                long staffCount =
                        fromDate == null || toDate == null
                                ? staffRepo.countActiveStaff()
                                : staffRepo.countActiveStaffBetween(fromDate, toDate);

                long supplierCustomerCount = supplierCount * customerCount;

                log.info(
                        "Supplier-Customer vs Staff analytics generated. Supplier Count: {}, Customer Count: {}, Product: {}, Staff Count: {}",
                        supplierCount,
                        customerCount,
                        supplierCustomerCount,
                        staffCount
                );

                yield List.of(
                        new PieChartDataDto("Supplier * Customer", supplierCustomerCount),
                        new PieChartDataDto("Staff", staffCount)
                );
            }
        };
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

        private double billAmount;
        private double creditAmount;
        private long billCount;
        private long creditCount;
    }
}