package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.analytics.AmountVsMonthDto;
import com.code.monks.csm.dto.analytics.AmountVsMonthRequestDto;
import com.code.monks.csm.dto.analytics.EntryCountDto;
import com.code.monks.csm.dto.analytics.PieChartDataDto;
import com.code.monks.csm.dto.analytics.PieChartRequestDto;
import com.code.monks.csm.dto.analytics.projection.CountView;
import com.code.monks.csm.dto.analytics.projection.MonthlyAmountView;
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

    private static final DateTimeFormatter MONTH_FORMATTER = DateTimeFormatter.ofPattern("MMM yyyy");

    @Override
    public List<EntryCountDto> getEntryCount(AmountVsMonthRequestDto request) {
        log.info(
                "Fetching entry count analytics. SupplierIds: {}, CustomerIds: {}",
                request.supplierIds(),
                request.customerIds()
        );

        List<Integer> supplierIds = normalizeIds(request.supplierIds());
        List<Integer> customerIds = normalizeIds(request.customerIds());

        List<CountView> billCounts = billEntryRepo.getMonthlyBillEntryCount(supplierIds, customerIds);
        List<CountView> creditCounts = creditEntryRepo.getMonthlyCreditEntryCount(supplierIds, customerIds);

        Map<YearMonth, MonthlyEntryCounts> monthlyMap = new TreeMap<>();

        mergeBillCounts(monthlyMap, billCounts);
        mergeCreditCounts(monthlyMap, creditCounts);
        List<EntryCountDto> response = buildEntryCountResponse(monthlyMap);

        log.info(
                "Entry count analytics fetched successfully. Total months: {}",
                response.size()
        );

        return response;
    }

    @Override
    public List<AmountVsMonthDto> getAmountVsMonth(AmountVsMonthRequestDto request) {

        log.info(
                "Fetching amount vs month analytics. SupplierIds: {}, CustomerIds: {}",
                request.supplierIds(),
                request.customerIds()
        );

        List<Integer> supplierIds = normalizeIds(request.supplierIds());
        List<Integer> customerIds = normalizeIds(request.customerIds());

        List<MonthlyAmountView> billData =
                billEntryRepo.getMonthlyBillAmount(
                        supplierIds,
                        customerIds
                );

        List<MonthlyAmountView> creditData =
                creditEntryRepo.getMonthlyCreditAmount(
                        supplierIds,
                        customerIds
                );

        Map<YearMonth, MonthlyTotals> monthlyMap = new TreeMap<>();

        mergeBillData(monthlyMap, billData);
        mergeCreditData(monthlyMap, creditData);

        List<AmountVsMonthDto> response = buildResponse(monthlyMap);
        log.info(
                "Amount vs month analytics fetched successfully. Total months: {}",
                response.size()
        );

        return response;
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

    private void mergeBillData(Map<YearMonth, MonthlyTotals> monthlyMap, List<MonthlyAmountView> billData) {

        billData.
                stream()
                .filter(item -> item.year() != null)
                .filter(item -> item.month() != null)
                .forEach(item -> {
            YearMonth yearMonth =
                    YearMonth.of(
                            item.year(),
                            item.month()
                    );
            monthlyMap
                    .computeIfAbsent(
                            yearMonth,
                            ym -> new MonthlyTotals()
                    )
                    .setBillAmount(item.amount());
        });
    }

    private void mergeCreditData(Map<YearMonth, MonthlyTotals> monthlyMap, List<MonthlyAmountView> creditData) {

        creditData.stream()
                .filter(item -> item.year() != null)
                .filter(item -> item.month() != null)
                .forEach(item -> {
            YearMonth yearMonth =
                    YearMonth.of(
                            item.year(),
                            item.month()
                    );

            monthlyMap
                    .computeIfAbsent(
                            yearMonth,
                            ym -> new MonthlyTotals()
                    )
                    .setCreditAmount(item.amount());
        });
    }

    private List<AmountVsMonthDto> buildResponse(Map<YearMonth, MonthlyTotals> monthlyMap) {

        return monthlyMap.entrySet()
                .stream()
                .map(entry -> {

                    YearMonth yearMonth = entry.getKey();
                    MonthlyTotals totals = entry.getValue();

                    return new AmountVsMonthDto(
                            yearMonth.format(MONTH_FORMATTER),
                            totals.getBillAmount(),
                            totals.getCreditAmount()
                    );
                })
                .toList();
    }

    private void mergeBillCounts(Map<YearMonth, MonthlyEntryCounts> monthlyMap, List<CountView> billCounts) {
        billCounts.stream()
                .filter(item -> item.year() != null)
                .filter(item -> item.month() != null)
                .forEach(item -> {
                    YearMonth yearMonth = YearMonth.of(item.year(), item.month());
                    monthlyMap
                            .computeIfAbsent(yearMonth, ym -> new MonthlyEntryCounts())
                            .setBillEntryCount(item.count());
                });
    }

    private void mergeCreditCounts(Map<YearMonth, MonthlyEntryCounts> monthlyMap, List<CountView> creditCounts) {
        creditCounts.stream()
                .filter(item -> item.year() != null)
                .filter(item -> item.month() != null)
                .forEach(item -> {
                    YearMonth yearMonth = YearMonth.of(item.year(), item.month());
                    monthlyMap
                            .computeIfAbsent(yearMonth, ym -> new MonthlyEntryCounts())
                            .setCreditEntryCount(item.count());
                });
    }

    private List<EntryCountDto> buildEntryCountResponse(Map<YearMonth, MonthlyEntryCounts> monthlyMap) {
        return monthlyMap.entrySet()
                .stream()
                .map(entry -> {
                    YearMonth yearMonth = entry.getKey();
                    MonthlyEntryCounts totals = entry.getValue();
                    return new EntryCountDto(
                            yearMonth.format(MONTH_FORMATTER),
                            totals.getBillEntryCount(),
                            totals.getCreditEntryCount()
                    );
                })
                .toList();
    }

    @Getter
    @Setter
    private static class MonthlyTotals {

        private Long billAmount = 0L;
        private Long creditAmount = 0L;
    }

    @Getter
    @Setter
    private static class MonthlyEntryCounts {

        private Long billEntryCount = 0L;
        private Long creditEntryCount = 0L;
    }
}