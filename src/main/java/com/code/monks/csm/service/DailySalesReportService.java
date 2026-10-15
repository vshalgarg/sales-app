package com.code.monks.csm.service;

import com.code.monks.csm.dto.email.DailySalesReportDto;
import com.code.monks.csm.repository.BillEntryRepo;
import com.code.monks.csm.repository.CreditEntryRepo;
import com.code.monks.csm.repository.RetailSupplierDepositRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

@Service
public class DailySalesReportService {

    private final CreditEntryRepo creditEntryRepo;
    private final BillEntryRepo billEntryRepo;
    private final RetailSupplierDepositRepository depositRepo;

    public DailySalesReportService(
            CreditEntryRepo creditEntryRepo,
            BillEntryRepo billEntryRepo,
            RetailSupplierDepositRepository depositRepo) {
        this.creditEntryRepo = creditEntryRepo;
        this.billEntryRepo = billEntryRepo;
        this.depositRepo = depositRepo;
    }

    @Transactional(readOnly = true)
    public DailySalesReportDto generateReport(LocalDate reportDate) {

        LocalDateTime start = reportDate.atStartOfDay();
        LocalDateTime end = reportDate.plusDays(1).atStartOfDay();

        // 1. Total credit amount
        BigInteger totalCreditAmount =
                creditEntryRepo.sumCreditAmountBetween(start, end);

        if (totalCreditAmount == null) {
            totalCreditAmount = BigInteger.ZERO;
        }

        // 2. Total bills created
        long totalBills =
                billEntryRepo
                        .countByCreatedAtGreaterThanEqualAndCreatedAtLessThan(
                                start, end);

        // 3. Total credit entries created
        long totalCredits =
                creditEntryRepo
                        .countByCreatedAtGreaterThanEqualAndCreatedAtLessThan(
                                start, end);

        // 4. Unique retailers with deposits on the report date
        Set<Integer> retailerIds = new HashSet<>(
                depositRepo.findDistinctRetailerIdsByDepositDate(
                        reportDate, reportDate.plusDays(1)));

        // 5. Unique suppliers from bills, credits and deposits
        Set<Integer> supplierIds = new HashSet<>();

        supplierIds.addAll(
                billEntryRepo.findDistinctSupplierIdsCreatedBetween(
                        start, end));

        supplierIds.addAll(
                creditEntryRepo.findDistinctSupplierIdsCreatedBetween(
                        start, end));

        supplierIds.addAll(
                depositRepo.findDistinctSupplierIdsByDepositDate(
                        reportDate, reportDate.plusDays(1)));

        // 6. Unique customers from bills and credits
        Set<Integer> customerIds = new HashSet<>();

        customerIds.addAll(
                billEntryRepo.findDistinctCustomerIdsCreatedBetween(
                        start, end));

        customerIds.addAll(
                creditEntryRepo.findDistinctCustomerIdsCreatedBetween(
                        start, end));

        return new DailySalesReportDto(
                reportDate,
                totalCreditAmount,
                totalBills,
                totalCredits,
                retailerIds.size(),
                supplierIds.size(),
                customerIds.size()
        );
    }
}

