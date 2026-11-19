package com.code.monks.csm.service;

import com.code.monks.csm.dto.ledger.PendingPaymentReportDTO;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public interface PendingPaymentReportService {

    List<PendingPaymentReportDTO> getPendingPayments(LocalDate asOfDate);

    BigDecimal getTotalOutstanding(List<PendingPaymentReportDTO> pendingPayments);
}

