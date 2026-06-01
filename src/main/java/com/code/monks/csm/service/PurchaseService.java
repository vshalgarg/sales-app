package com.code.monks.csm.service;

import com.code.monks.csm.dto.purchase.PurchaseDetailResponse;
import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.dto.request.CopySupplierDetailsRequest;
import com.code.monks.csm.dto.request.UpdatePurchaseEntryReq;
import com.code.monks.csm.dto.response.AddPurchaseEntryResponseDto;
import com.code.monks.csm.dto.response.CopySupplierDetailsResponseDTO;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.SearchPurchaseEntryResponse;
import org.springframework.util.MultiValueMap;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.Map;

public interface PurchaseService {
    AddPurchaseEntryResponseDto addPurchaseEntry(
            AddPurchaseEntryRequestDto requestDto,
            MultiValueMap<String, MultipartFile> supplierImages
    );
    PagedResponseDto<SearchPurchaseEntryResponse> searchPurchaseHistory(
            LocalDate fromDate,
            LocalDate toDate,
            Integer supplierId,
            Integer customerId,
            Integer staffId,
            int page,
            int size);

    Map<String, Object> updatePurchaseEntry(
            int id,
            UpdatePurchaseEntryReq req,
            MultiValueMap<String, MultipartFile> supplierImages
    );

    Map<String, Object> deletePurchaseEntry(int id);
    PurchaseDetailResponse getPurchaseById(int id);
    CopySupplierDetailsResponseDTO copySupplierDetailsPerCustomer(CopySupplierDetailsRequest request);
}
