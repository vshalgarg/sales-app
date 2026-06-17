package com.code.monks.csm.service;

import com.code.monks.csm.dto.ledger.LedgerResponseDto;
import com.code.monks.csm.enums.LedgerViewTypeEnum;

public interface LedgerService {
    LedgerResponseDto getLedger(
            Integer supplierId,
            Integer customerId,
            LedgerViewTypeEnum ledgerType
    );
}
