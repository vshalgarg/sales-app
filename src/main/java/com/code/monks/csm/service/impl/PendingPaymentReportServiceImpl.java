package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.ledger.PendingPaymentReportDTO;
import com.code.monks.csm.dto.ledger.PendingBillAmountView;
import com.code.monks.csm.dto.ledger.PendingReceivedAmountView;
import com.code.monks.csm.repository.BillEntryRepo;
import com.code.monks.csm.repository.CreditEntryRepo;
import com.code.monks.csm.service.PendingPaymentReportService;
import com.code.monks.csm.utils.MoneyUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PendingPaymentReportServiceImpl implements PendingPaymentReportService {

    private final BillEntryRepo billEntryRepository;
    private final CreditEntryRepo creditEntryRepository;

    @Transactional(readOnly = true)
    public List<PendingPaymentReportDTO> getPendingPayments(LocalDate asOfDate) {

        List<PendingBillAmountView> billAmounts = billEntryRepository.getPendingBillAmounts(asOfDate);
        List<PendingReceivedAmountView> receivedAmounts = creditEntryRepository.getPendingReceivedAmounts(asOfDate);
        Map<String, BigInteger> receivedAmountMap = new HashMap<>();

        for (PendingReceivedAmountView received : receivedAmounts) {
            String key = getKey(received.getCustomerId(), received.getSupplierId());
            receivedAmountMap.put(key, received.getAmount() == null ? BigInteger.ZERO : received.getAmount());
        }
        List<PendingPaymentReportDTO> result = new ArrayList<>();

        for (PendingBillAmountView bill : billAmounts) {
            String key = getKey(bill.getCustomerId(), bill.getSupplierId());
            BigInteger totalBillAmount = bill.getAmount() == null ? BigInteger.ZERO : bill.getAmount();
            BigInteger totalReceivedAmount = receivedAmountMap.getOrDefault(key,BigInteger.ZERO);
            BigInteger pendingAmount = totalBillAmount.subtract(totalReceivedAmount);
            if (pendingAmount.compareTo(BigInteger.ZERO) != 0) {
                BigDecimal pendingInRupees = MoneyUtil.toRupee(pendingAmount);
                result.add(new PendingPaymentReportDTO(
                                bill.getCustomerId(),
                                bill.getCustomerName(),
                                bill.getSupplierId(),
                                bill.getSupplierName(),
                                pendingInRupees)
                );
            }
        }
        return result;
    }

    public BigDecimal getTotalOutstanding(List<PendingPaymentReportDTO> pendingPayments
    ) {
        BigDecimal total = BigDecimal.ZERO;
        for (PendingPaymentReportDTO payment : pendingPayments) {
            total = total.add(payment.pendingAmount());
        }
        return total;
    }
    private String getKey(Integer customerId, Integer supplierId) {
        return customerId + "_" + supplierId;
    }
}


