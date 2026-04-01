package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.AddSupplierRequestDto;
import com.code.monks.csm.dto.request.DeleteSupplierRequestDto;
import com.code.monks.csm.dto.request.UpdateSupplierRequestDto;
import com.code.monks.csm.dto.response.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;


import java.util.List;

public interface SupplierService {
    AddSupplierResponseDto addSupplier(AddSupplierRequestDto requestDto);
    PagedResponseDto<SupplierListResponseDto> getSuppliers(int page, int size);
    DeleteSupplierResponseDto deleteSupplier(DeleteSupplierRequestDto requestDto);
    PagedResponseDto<SupplierListResponseDto> searchSuppliers(String keyword, Pageable pageable);
    List<SupplierSummaryDto> getAllSuppliers();
    void updateSupplier(Integer id, UpdateSupplierRequestDto request);
    GetSupplierByIdResponseDto getSupplierById(Integer id);

}
