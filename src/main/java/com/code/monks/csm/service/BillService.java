package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.BillEntryRequestDto;
import com.code.monks.csm.dto.request.BillUpdateRequest;
import com.code.monks.csm.dto.response.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface BillService {
    BillEntryResponseDto addBill(BillEntryRequestDto requestDto);
    List<GetBillEntries> getBillEntries();
    EditBillEntryResponse updateBill(String billNumber, BillUpdateRequest request);
    PagedResponseDto<SearchBillEntryResponse> searchBillHistory(
            LocalDate fromDate,
            LocalDate toDate,
            Integer supplierId,
            Integer customerId,
            int page,
            int size);
}
