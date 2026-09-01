package com.code.monks.csm.service;

import com.code.monks.csm.dto.response.PurchaseHistoryResponseDto;

import java.time.LocalDate;
import java.util.List;

public interface PurchaseExcelService {
    byte[] generateExcel(List<PurchaseHistoryResponseDto> entries, LocalDate fromDate, LocalDate toDate);

    String buildPurchaseExcelFilename(List<PurchaseHistoryResponseDto> entries, LocalDate fromDate, LocalDate toDate);
}
