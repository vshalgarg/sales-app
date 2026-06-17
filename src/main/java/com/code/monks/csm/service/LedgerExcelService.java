package com.code.monks.csm.service;

import com.code.monks.csm.dto.ledger.LedgerResponseDto;

public interface LedgerExcelService {
    byte[] generateExcel(LedgerResponseDto ledger);
}
