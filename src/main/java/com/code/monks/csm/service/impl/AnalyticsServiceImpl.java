package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.analytics.ChartDataDto;
import com.code.monks.csm.dto.analytics.DatasetDto;
import com.code.monks.csm.dto.analytics.MetricType;
import com.code.monks.csm.dto.analytics.MonthlyDataPoint;
import com.code.monks.csm.dto.analytics.MonthlyAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.MonthlyAnalyticsResponseDto;
import com.code.monks.csm.dto.analytics.StaffAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.StaffAnalyticsResponseDto;
import com.code.monks.csm.dto.analytics.StaffMetricType;
import com.code.monks.csm.dto.analytics.CustomerAmountAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.CustomerAmountAnalyticsResponseDto;
import com.code.monks.csm.dto.analytics.SupplierAmountAnalyticsRequestDto;
import com.code.monks.csm.dto.analytics.SupplierAmountAnalyticsResponseDto;
import com.code.monks.csm.dto.analytics.projection.CustomerAmountView;
import com.code.monks.csm.dto.analytics.projection.MonthlyAnalyticsView;
import com.code.monks.csm.dto.analytics.projection.StaffAnalyticsView;
import com.code.monks.csm.dto.analytics.projection.SupplierAmountView;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.StaffEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.repository.*;
import com.code.monks.csm.service.AnalyticsService;
import com.code.monks.csm.utils.MoneyUtil;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class AnalyticsServiceImpl implements AnalyticsService {

    private final BillEntryRepo billEntryRepo;
    private final CreditEntryRepo creditEntryRepo;
    private final CustomerRepo customerRepo;
    private final SupplierRepo supplierRepo;
    private final StaffRepo staffRepo;
    private final PurchaseEntryRepo purchaseEntryRepo;

    @Override
    public StaffAnalyticsResponseDto getStaffAnalytics(StaffAnalyticsRequestDto request) {
        log.info("Fetching staff analytics from {} to {}", request.fromDate(), request.toDate());

        LocalDate fromDate = request.fromDate();
        LocalDate toDate = request.toDate();
        if (fromDate == null && toDate == null) {
            toDate = LocalDate.now();
            fromDate = toDate.minusMonths(11).withDayOfMonth(1);
        }

        List<StaffAnalyticsView> supplierData = purchaseEntryRepo.getStaffSupplierAnalytics(fromDate, toDate);
        List<StaffAnalyticsView> customerData = purchaseEntryRepo.getStaffCustomerAnalytics(fromDate, toDate);
        log.info("Analytics data fetched. supplierRecords={}, customerRecords={}", supplierData.size(), customerData.size());

        Map<Integer, String> staffNameMap = staffRepo.findAll()
                .stream()
                //.filter(s -> s.getStatus() == StatusEnum.ACTIVE)
                .collect(Collectors.toMap(StaffEntity::getId, StaffEntity::getStaffName));

        Set<Integer> validStaffIds = new HashSet<>();
        supplierData.stream()
                .map(StaffAnalyticsView::getStaffId)
                .filter(staffNameMap::containsKey)
                .forEach(validStaffIds::add);
        customerData.stream()
                .map(StaffAnalyticsView::getStaffId)
                .filter(staffNameMap::containsKey)
                .forEach(validStaffIds::add);

        List<Integer> sortedStaffIds = validStaffIds.stream()
                .sorted(Comparator.comparing(staffNameMap::get))
                .toList();

        List<String> labels = sortedStaffIds.stream()
                .map(staffNameMap::get)
                .toList();

        Map<Integer, Long> supplierCountMap = supplierData.stream()
                .filter(v -> staffNameMap.containsKey(v.getStaffId()))
                .collect(Collectors.toMap(StaffAnalyticsView::getStaffId, StaffAnalyticsView::getCount));

        Map<Integer, Long> customerCountMap = customerData.stream()
                .filter(v -> staffNameMap.containsKey(v.getStaffId()))
                .collect(Collectors.toMap(StaffAnalyticsView::getStaffId, StaffAnalyticsView::getCount));

        List<Long> supplierCounts = sortedStaffIds.stream()
                .map(id -> supplierCountMap.getOrDefault(id, 0L))
                .toList();

        List<Long> customerCounts = sortedStaffIds.stream()
                .map(id -> customerCountMap.getOrDefault(id, 0L))
                .toList();

        List<Long> totalCounts = sortedStaffIds.stream()
                .map(id -> supplierCountMap.getOrDefault(id, 0L) + customerCountMap.getOrDefault(id, 0L))
                .toList();

        DatasetDto supplierDataset = DatasetDto.builder()
                .label(StaffMetricType.SUPPLIER_COUNT.getLabel())
                .data(supplierCounts)
                .unit(StaffMetricType.SUPPLIER_COUNT.getUnit())
                .build();

        DatasetDto customerDataset = DatasetDto.builder()
                .label(StaffMetricType.CUSTOMER_COUNT.getLabel())
                .data(customerCounts)
                .unit(StaffMetricType.CUSTOMER_COUNT.getUnit())
                .build();

        DatasetDto totalDataset = DatasetDto.builder()
                .label(StaffMetricType.TOTAL_COUNT.getLabel())
                .data(totalCounts)
                .unit(StaffMetricType.TOTAL_COUNT.getUnit())
                .build();

        ChartDataDto supplierVsStaff = ChartDataDto.builder()
                .labels(labels)
                .datasets(List.of(supplierDataset))
                .build();

        ChartDataDto customerVsStaff = ChartDataDto.builder()
                .labels(labels)
                .datasets(List.of(customerDataset))
                .build();

        ChartDataDto supplierAndCustomerVsStaff = ChartDataDto.builder()
                .labels(labels)
                .datasets(List.of(totalDataset))
                .build();

        log.info("Staff analytics fetched: {} staff members, date range: {} to {}", labels.size(), fromDate, toDate);

        return StaffAnalyticsResponseDto.builder()
                .supplierVsStaff(supplierVsStaff)
                .customerVsStaff(customerVsStaff)
                .supplierAndCustomerVsStaff(supplierAndCustomerVsStaff)
                .build();
    }

    @Override
    public SupplierAmountAnalyticsResponseDto getSupplierAmountAnalytics(SupplierAmountAnalyticsRequestDto request) {
        log.info("Fetching supplier amount analytics from {} to {}, supplierIds: {}", request.fromDate(), request.toDate(), request.supplierIds());

        List<Integer> supplierIds = normalizeIds(request.supplierIds());
        LocalDate fromDate = request.fromDate();
        LocalDate toDate = request.toDate();
        if (fromDate == null) {
            fromDate = toDate != null
                    ? toDate.minusMonths(11).withDayOfMonth(1)
                    : LocalDate.now().minusMonths(11).withDayOfMonth(1);
        }
        if (toDate == null) {
            toDate = LocalDate.now();
        }

        List<SupplierAmountView> billData = billEntryRepo.getSupplierBillAnalytics(supplierIds, fromDate, toDate);

        if (supplierIds == null && billData.size() > 10) {
            billData = billData.subList(0, 10);
        }

        List<Integer> activeSupplierIds = billData.stream()
                .map(SupplierAmountView::getSupplierId)
                .toList();

        List<SupplierAmountView> creditData = activeSupplierIds.isEmpty()
                ? List.of()
                : creditEntryRepo.getSupplierCreditAnalytics(activeSupplierIds, fromDate, toDate);

        Map<Integer, String> supplierNameMap = supplierRepo.findAll()
                .stream()
                .collect(Collectors.toMap(SupplierEntity::getId, SupplierEntity::getSupplierName));

        Map<Integer, Long> creditAmountMap = creditData.stream()
                .collect(Collectors.toMap(SupplierAmountView::getSupplierId, SupplierAmountView::getAmount));

        List<String> labels = new ArrayList<>();
        List<BigDecimal> billAmounts = new ArrayList<>();
        List<BigDecimal> creditAmounts = new ArrayList<>();

        for (SupplierAmountView bill : billData) {
            Integer sid = bill.getSupplierId();
            if (!supplierNameMap.containsKey(sid)) {
                continue;
            }
            labels.add(supplierNameMap.get(sid));
            billAmounts.add(MoneyUtil.toRupee(bill.getAmount()));
            creditAmounts.add(MoneyUtil.toRupee(creditAmountMap.getOrDefault(sid, 0L)));
        }

        DatasetDto billDataset = DatasetDto.builder()
                .label(MetricType.BILL_AMOUNT.getLabel())
                .data(billAmounts)
                .unit(MetricType.BILL_AMOUNT.getUnit())
                .build();

        DatasetDto creditDataset = DatasetDto.builder()
                .label(MetricType.CREDIT_AMOUNT.getLabel())
                .data(creditAmounts)
                .unit(MetricType.CREDIT_AMOUNT.getUnit())
                .build();

        ChartDataDto chartData = ChartDataDto.builder()
                .labels(labels)
                .datasets(List.of(billDataset, creditDataset))
                .build();

        log.info("Supplier amount analytics fetched: {} suppliers, date range: {} to {}", labels.size(), fromDate, toDate);

        return SupplierAmountAnalyticsResponseDto.builder()
                .supplierVsAmount(chartData)
                .build();
    }

    @Override
    public CustomerAmountAnalyticsResponseDto getCustomerAmountAnalytics(CustomerAmountAnalyticsRequestDto request) {
        log.info("Fetching customer amount analytics from {} to {}, customerIds: {}", request.fromDate(), request.toDate(), request.customerIds());

        List<Integer> customerIds = normalizeIds(request.customerIds());
        LocalDate fromDate = request.fromDate();
        LocalDate toDate = request.toDate();
        if (fromDate == null) {
            fromDate = toDate != null
                    ? toDate.minusMonths(11).withDayOfMonth(1)
                    : LocalDate.now().minusMonths(11).withDayOfMonth(1);
        }
        if (toDate == null) {
            toDate = LocalDate.now();
        }

        List<CustomerAmountView> billData = billEntryRepo.getCustomerBillAnalytics(customerIds, fromDate, toDate);

        if (customerIds == null && billData.size() > 10) {
            billData = billData.subList(0, 10);
        }

        List<Integer> customerIdsWithBills = billData.stream()
                .map(CustomerAmountView::getCustomerId)
                .toList();

        List<CustomerAmountView> creditData = customerIdsWithBills.isEmpty()
                ? List.of()
                : creditEntryRepo.getCustomerCreditAnalytics(customerIdsWithBills, fromDate, toDate);

        log.info("Analytics data fetched. billRecords={}, creditRecords={}", billData.size(), creditData.size());

        Map<Integer, String> customerNameMap = customerRepo.findAll()
                .stream()
                .collect(Collectors.toMap(CustomerEntity::getId, CustomerEntity::getCustomerName));

        Map<Integer, Long> creditAmountMap = creditData.stream()
                .collect(Collectors.toMap(CustomerAmountView::getCustomerId, CustomerAmountView::getAmount));

        List<String> labels = new ArrayList<>();
        List<BigDecimal> billAmounts = new ArrayList<>();
        List<BigDecimal> creditAmounts = new ArrayList<>();

        for (CustomerAmountView bill : billData) {
            Integer cid = bill.getCustomerId();
            if (!customerNameMap.containsKey(cid)) {
                continue;
            }
            labels.add(customerNameMap.get(cid));
            billAmounts.add(MoneyUtil.toRupee(bill.getAmount()));
            creditAmounts.add(MoneyUtil.toRupee(creditAmountMap.getOrDefault(cid, 0L)));
        }

        DatasetDto billDataset = DatasetDto.builder()
                .label(MetricType.BILL_AMOUNT.getLabel())
                .data(billAmounts)
                .unit(MetricType.BILL_AMOUNT.getUnit())
                .build();

        DatasetDto creditDataset = DatasetDto.builder()
                .label(MetricType.CREDIT_AMOUNT.getLabel())
                .data(creditAmounts)
                .unit(MetricType.CREDIT_AMOUNT.getUnit())
                .build();

        ChartDataDto chartData = ChartDataDto.builder()
                .labels(labels)
                .datasets(List.of(billDataset, creditDataset))
                .build();

        log.info("Customer amount analytics fetched: {} customers, date range: {} to {}", labels.size(), fromDate, toDate);

        return CustomerAmountAnalyticsResponseDto.builder()
                .customerVsAmount(chartData)
                .build();
    }

    @Override
    public MonthlyAnalyticsResponseDto getMonthlyAnalytics(MonthlyAnalyticsRequestDto request) {

        log.info(
                "Fetching monthly analytics. fromDate: {}, toDate: {}, supplierIds: {}, customerIds: {}",
                request.fromDate(), request.toDate(),
                request.supplierIds(),
                request.customerIds()
        );

        List<Integer> supplierIds = normalizeIds(request.supplierIds());
        List<Integer> customerIds = normalizeIds(request.customerIds());
        LocalDate fromDate = request.fromDate();
        LocalDate toDate = request.toDate();
        if (fromDate == null) {
            fromDate = toDate != null
                    ? toDate.minusMonths(11).withDayOfMonth(1)
                    : LocalDate.now().minusMonths(11).withDayOfMonth(1);
        }
        if (toDate == null) {
            toDate = LocalDate.now();
        }

        List<MonthlyAnalyticsView> billAnalytics = billEntryRepo.getMonthlyBillAnalytics(supplierIds, customerIds, fromDate, toDate);
        List<MonthlyAnalyticsView> creditAnalytics = creditEntryRepo.getMonthlyCreditAnalytics(supplierIds, customerIds, fromDate, toDate);
        log.info("Analytics data fetched. billRecords={}, creditRecords={}", billAnalytics.size(), creditAnalytics.size());

        Map<YearMonth, MonthlyAnalyticsAccumulator> monthlyMap = new TreeMap<>();
        for (MonthlyAnalyticsView bill : billAnalytics) {
            YearMonth yearMonth = YearMonth.of(bill.getYear(), bill.getMonth());
            MonthlyAnalyticsAccumulator data = monthlyMap.computeIfAbsent(yearMonth, key -> new MonthlyAnalyticsAccumulator());
            data.setBillAmount(bill.getAmount());
            data.setBillCount(bill.getCount());
        }

        for (MonthlyAnalyticsView credit : creditAnalytics) {
            YearMonth yearMonth = YearMonth.of(credit.getYear(), credit.getMonth());
            MonthlyAnalyticsAccumulator data = monthlyMap.computeIfAbsent(yearMonth, key -> new MonthlyAnalyticsAccumulator());
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

        List<MonthlyDataPoint> records =
                monthlyMap.entrySet()
                        .stream()
                        .map(entry -> {
                            YearMonth yearMonth = entry.getKey();
                            MonthlyAnalyticsAccumulator data = entry.getValue();
                            return new MonthlyDataPoint(
                                    yearMonth.getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH)+ "'" + String.format("%02d", yearMonth.getYear() % 100),
                                    MoneyUtil.toRupee(data.getBillAmount()),
                                    MoneyUtil.toRupee(data.getCreditAmount()),
                                    data.getBillCount(),
                                    data.getCreditCount()
                            );
                        })
                        .toList();

        List<String> labels = records.stream()
                                  .map(MonthlyDataPoint::month)
                                  .toList();

        List<DatasetDto> datasets = Arrays.stream(MetricType.values())
                .map(type -> DatasetDto.builder()
                        .label(type.getLabel())
                        .data(records.stream().map(type::extract).toList())
                        .unit(type.getUnit())
                        .build())
                .toList();

        log.info("Monthly analytics fetched: {} months from {} to {}", records.size(), fromDate, toDate);

        return MonthlyAnalyticsResponseDto.builder()
                .labels(labels)
                .datasets(datasets)
                .build();
    }


    private List<Integer> normalizeIds(
            List<Integer> ids
    ) {
        return ids == null || ids.isEmpty() ? null : ids;
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