package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.AddSupplierRequestDto;
import com.code.monks.csm.dto.request.DeleteSupplierRequestDto;
import com.code.monks.csm.dto.response.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;


import java.util.List;

public interface SupplierService {
    AddSupplierResponseDto addSupplier(AddSupplierRequestDto requestDto);
    PagedResponseDto<GetSuppliersDto> getSuppliers(int page, int size);
    DeleteSupplierResponseDto deleteSupplier(DeleteSupplierRequestDto requestDto);
    List<SearchSuppliersResponseDto> searchSuppliers(String keyword);
    Page<SearchSuppliersResponseDto> searchSuppliers(String keyword, Pageable pageable);

    List<GetSuppliersDto> getAllSuppliers();
}
