package com.code.monks.csm.service;

import com.code.monks.csm.dto.email.DailySalesReportDto;
import com.code.monks.csm.repository.*;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigInteger;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;
@AllArgsConstructor
@Service
public class DailySalesReportService {

    private final CreditEntryRepo creditEntryRepo;
    private final BillEntryRepo billEntryRepo;
    private final RetailSupplierDepositRepository depositRepo;
    private final RetailRepository retailRepo;
    private final PurchaseEntryRepo purchaseEntryRepo;
    @Transactional(readOnly = true)
    public DailySalesReportDto generateReport(LocalDate reportDate) {
        LocalDateTime start = reportDate.atStartOfDay();
        LocalDateTime end = reportDate.plusDays(1).atStartOfDay();

        BigInteger totalCreditAmount = creditEntryRepo.sumCreditAmountBetween(start, end);
        if (totalCreditAmount == null) {
            totalCreditAmount = BigInteger.ZERO;
        }

        BigInteger totalDebitAmount = billEntryRepo.sumBillAmountBetween(start, end);

        if (totalDebitAmount == null) {
            totalDebitAmount = BigInteger.ZERO;
        }

        long totalBills = billEntryRepo.countByCreatedAtGreaterThanEqualAndCreatedAtLessThan(start, end);

        long totalCredits = creditEntryRepo.countByCreatedAtGreaterThanEqualAndCreatedAtLessThan(start, end);

//        Set<Integer> retailerIds = new HashSet<>(depositRepo.findDistinctRetailerIdsByDepositDate(
//                        reportDate, reportDate.plusDays(1)));

        Set<Integer> retailerIds = new HashSet<>();

        retailerIds.addAll(
                retailRepo.findDistinctRetailerIdsCreatedBetween(start, end)
        );
        Set<Integer> supplierIds = new HashSet<>();

//        supplierIds.addAll(billEntryRepo.findDistinctSupplierIdsCreatedBetween(start, end));
//
//        supplierIds.addAll(creditEntryRepo.findDistinctSupplierIdsCreatedBetween(start, end));

        supplierIds.addAll(purchaseEntryRepo.findDistinctSupplierIdsCreatedBetween(start,end));

        Set<Integer> customerIds = new HashSet<>();

//        customerIds.addAll(billEntryRepo.findDistinctCustomerIdsCreatedBetween(start, end));
//
//        customerIds.addAll(creditEntryRepo.findDistinctCustomerIdsCreatedBetween(start, end));

        customerIds.addAll(purchaseEntryRepo.findDistinctCustomerIdsCreatedBetween(start, end));

        return new DailySalesReportDto(
                reportDate,
                totalCreditAmount,
                totalDebitAmount,
                totalBills,
                totalCredits,
                retailerIds.size(),
                supplierIds.size(),
                customerIds.size()
        );


    }
}

