package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.RetailRequestDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.RetailResponseDto;
import com.code.monks.csm.dto.response.RetailerListResponseDto;

import java.time.LocalDate;

public interface RetailService {
    void createRetail(RetailRequestDto request);
    void updateRetail(Long retailId, RetailRequestDto request);
    RetailResponseDto getRetailDetails(Long retailId);
    PagedResponseDto<RetailerListResponseDto> searchRetailers(
            LocalDate fromDate,
            LocalDate toDate,
            Integer customerId,
            Integer staffId,
            Integer supplierId,
            int page,
            int size
    );
}
