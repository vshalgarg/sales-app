package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.BillEntryRequestDto;
import com.code.monks.csm.dto.request.BillUpdateRequest;
import com.code.monks.csm.dto.response.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public interface BillService {
    BillEntryResponseDto addBill(BillEntryRequestDto requestDto, List<MultipartFile> images);
    List<GetBillEntries> getBillEntries();
    EditBillEntryResponse updateBill(String billNumber, BillUpdateRequest request, List<MultipartFile> images);
    PagedResponseDto<SearchBillEntryResponse> searchBillHistory(
            LocalDate fromDate,
            LocalDate toDate,
            Integer supplierId,
            Integer customerId,
            int page,
            int size);

    Map<String, Object> deleteBillEntry(String billNumber);
}
