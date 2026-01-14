package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.dto.request.UpdatePurchaseEntryReq;
import com.code.monks.csm.dto.response.AddPurchaseEntryResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.SearchPurchaseEntryResponse;

import java.time.LocalDate;
import java.util.Map;

public interface PurchaseService {
    AddPurchaseEntryResponseDto addPurchaseEntry(AddPurchaseEntryRequestDto addPurchaseEntryRequestDto);
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
