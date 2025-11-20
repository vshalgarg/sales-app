package com.code.monks.csm.service;


import com.code.monks.csm.dto.request.AddCustomerRequestDto;
import com.code.monks.csm.dto.request.DeleteCustomerRequestDto;
import com.code.monks.csm.dto.response.*;

import java.util.List;

public interface CustomerService {
    AddCustomerResponseDto addCustomer(AddCustomerRequestDto requestDto);
    PagedResponseDto<GetCustomersDto> getCustomers(int page, int size);
    DeleteCustomerResponseDto deleteCustomer(DeleteCustomerRequestDto requestDto);
    List<SearchCustomersResponseDto> searchCustomers(String keyword);
}
