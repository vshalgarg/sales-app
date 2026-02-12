package com.code.monks.csm.service;


import com.code.monks.csm.dto.request.AddCustomerRequestDto;
import com.code.monks.csm.dto.request.DeleteCustomerRequestDto;
import com.code.monks.csm.dto.request.UpdateCustomerRequestDto;
import com.code.monks.csm.dto.response.*;
import jakarta.validation.Valid;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface CustomerService {
    AddCustomerResponseDto addCustomer(AddCustomerRequestDto requestDto);
    PagedResponseDto<GetCustomersDto> getCustomers(int page, int size);
    DeleteCustomerResponseDto deleteCustomer(DeleteCustomerRequestDto requestDto);
    PagedResponseDto<SearchCustomersResponseDto> searchCustomers(String keyword, Pageable pageable);

    List<GetCustomersDto> getAllCustomers();

    void updateCustomer(Integer id, @Valid UpdateCustomerRequestDto request);
    GetCustomerByIdResponseDto getCustomerById(Integer id);

}
