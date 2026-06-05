package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.CreateRetailerRequestDto;
import com.code.monks.csm.dto.request.RetailSupplierDepositRequestDto;
import com.code.monks.csm.dto.request.UpdateRetailSupplierRequestDto;
import com.code.monks.csm.dto.request.UpdateRetailerRequestDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.RetailResponseDto;
import com.code.monks.csm.dto.response.RetailerListResponseDto;
import com.code.monks.csm.dto.response.SupplierDepositHistoryResponseDto;

import java.time.LocalDate;
import java.util.List;

public interface RetailService {
    void createRetail(CreateRetailerRequestDto request);
    void updateRetail(Long retailId, UpdateRetailerRequestDto request);
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
    void addDeposit(RetailSupplierDepositRequestDto request);
    List<SupplierDepositHistoryResponseDto> getDepositHistory(Long retailId);
    void deleteRetailer(Long retailId);
    void updateRetailSupplier(
            Long retailId,
            Integer retailSupplierId,
            UpdateRetailSupplierRequestDto request
    );

    void deleteRetailSupplier(
            Long retailId,
            Integer retailSupplierId
    );

}
