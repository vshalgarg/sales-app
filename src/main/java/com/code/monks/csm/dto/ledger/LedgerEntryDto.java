package com.code.monks.csm.dto.ledger;

import lombok.Builder;

import java.math.BigDecimal;
import java.time.LocalDate;

@Builder
public record LedgerEntryDto(
        LocalDate date,
        String invoiceNo,
        String particular,
        BigDecimal debit,
        BigDecimal credit,
        BigDecimal runningBalance
) {
}
