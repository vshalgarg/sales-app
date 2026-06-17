package com.code.monks.csm.dto.ledger;

import com.code.monks.csm.enums.LedgerViewTypeEnum;
import lombok.Builder;

import java.math.BigDecimal;
import java.util.List;

@Builder
public record LedgerResponseDto(
        LedgerPartyDto party,
        LedgerViewTypeEnum ledgerType,
        BigDecimal totalDebit,
        BigDecimal totalCredit,
        BigDecimal balance,
        List<LedgerEntryDto> entries
) {
}
