package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.dto.request.UpdatePurchaseEntryReq;
import com.code.monks.csm.dto.response.AddPurchaseEntryResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.SearchPurchaseEntryResponse;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface PurchaseService {
    AddPurchaseEntryResponseDto addPurchaseEntry(
            AddPurchaseEntryRequestDto requestDto,
            List<MultipartFile> images
    );
    PagedResponseDto<SearchPurchaseEntryResponse> searchPurchaseHistory(
            LocalDate fromDate,
            LocalDate toDate,
            Integer supplierId,
            Integer customerId,
            int page,
            int size);

    Map<String, Object> updatePurchaseEntry(int id, UpdatePurchaseEntryReq req);

    Map<String, Object> deletePurchaseEntry(int id);
}
