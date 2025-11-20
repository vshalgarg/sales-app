package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.BillEntryRequestDto;
import com.code.monks.csm.dto.response.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface BillService {
    BillEntryResponseDto addBill(BillEntryRequestDto requestDto);
    List<GetBillEntries> getBillEntries();
    EditBillEntryResponse updateBill(String billNumber, Map<String, Object> updates);
    PagedResponseDto<SearchBillEntryResponse> searchBillHistory(
            LocalDate fromDate,
            LocalDate toDate,
            String supplierName,
            String customerName,
            int page,
            int size);
}
