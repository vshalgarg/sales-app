package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.BillEntryRequestDto;
import com.code.monks.csm.dto.request.BillUpdateRequest;
import com.code.monks.csm.dto.response.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface BillService {
    BillEntryResponseDto addBill(BillEntryRequestDto requestDto, List<MultipartFile> images);
    EditBillEntryResponse updateBill(Integer id, BillUpdateRequest request, List<MultipartFile> images);
    ReportPagedResponseDto<BillListResponseDto> searchBillHistory(
            LocalDate fromDate,
            LocalDate toDate,
            Integer supplierId,
            Integer customerId,
            int page,
            int size);

    Map<String, Object> deleteBillEntry(String billNumber);
    BillDetailResponseDto getBillDetail(String findByBillNumber);
}
