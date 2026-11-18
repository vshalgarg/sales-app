package com.code.monks.csm.dto.ledger;

import java.math.BigDecimal;

public record PendingPaymentReportDTO(
        Integer customerId,
        String customerName,
        Integer supplierId,
        String supplierName,
        BigDecimal pendingAmount
) {
}
