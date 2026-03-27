package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.ApiResponse;
import com.code.monks.csm.dto.request.AddCustomerRequestDto;
import com.code.monks.csm.dto.request.DeleteCustomerRequestDto;
import com.code.monks.csm.dto.request.UpdateCustomerRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.CustomerService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.code.monks.csm.constants.ApiPaths.*;

@RequestMapping(BASE)
@RestController
@AllArgsConstructor
@Slf4j
public class CustomerController {

    private final CustomerService customerService;

    @PostMapping(ADD_CUSTOMER)
    public ResponseEntity<AddCustomerResponseDto> addCustomer(
            @Valid @RequestBody AddCustomerRequestDto requestDto) {
        log.info("POST add customer api called with customerName: {}", requestDto.getCustomerName());

        AddCustomerResponseDto response = customerService.addCustomer(requestDto);
        log.info("Customer '{}' added successfully", requestDto.getCustomerName());

        return ResponseEntity.ok(response);
    }

    @GetMapping(GET_CUSTOMERS)
    public ResponseEntity<PagedResponseDto<CustomerListDto>> getCustomers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "8") int size
    ) {
        log.info("GET customers API called to retrieve customers (page={}, size={})", page, size);

        PagedResponseDto<CustomerListDto> response = customerService.getCustomers(page, size);
        log.info("Retrieved {} customers successfully", response.getContent().size());

        return ResponseEntity.ok(response);
    }

    @GetMapping(GET_CUSTOMERS_V2)
    public ResponseEntity<List<CustomerSummaryResponseDto>> getAllCustomers() {
        log.info("GET {} called to retrieve all customers", GET_CUSTOMERS_V2);

        List<CustomerSummaryResponseDto> response = customerService.getAllCustomers();

        log.info("Retrieved {} customers successfully..", response.size());

        return ResponseEntity.ok(response);
    }

    @PutMapping(DELETE_CUSTOMER)
    public ResponseEntity<DeleteCustomerResponseDto> deleteCustomer(
            @Valid @RequestBody DeleteCustomerRequestDto requestDto) {
        log.info("PUT delete customer api called to delete customer with Code: {}", requestDto.getCustomerCode());

        DeleteCustomerResponseDto response = customerService.deleteCustomer(requestDto);
        log.info("Customer with Code {} deleted successfully", requestDto.getCustomerCode());

        return ResponseEntity.ok(response);
    }

    @GetMapping(SEARCH_CUSTOMERS)
    public ResponseEntity<PagedResponseDto<CustomerListDto>> searchCustomers(
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ){
        log.info("Search customers API called with keyword: '{}', page: {}, size: {}",
                keyword, page, size);
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "customerName"));
        PagedResponseDto<CustomerListDto> response =
                customerService.searchCustomers(keyword, pageable);

        log.info("Search completed - returned {} customers (page {}/{})",
                response.getContent().size(), response.getPage(), response.getTotalPages());

        return ResponseEntity.ok(response);
    }

    @PutMapping(UPDATE_CUSTOMER)
    public ResponseEntity<ApiResponse<Void>> updateCustomer(
            @PathVariable Integer id,
            @RequestBody UpdateCustomerRequestDto request) {

        customerService.updateCustomer(id, request);

        return ResponseEntity.ok(
                ApiResponse.success("Customer updated successfully")
        );
    }

    @GetMapping(GET_CUSTOMER_BY_ID)
    public ResponseEntity<ApiResponse<GetCustomerByIdResponseDto>> getCustomerById(
            @PathVariable Integer id) {

        log.info("GET customer by id={} called", id);

        GetCustomerByIdResponseDto response =
                customerService.getCustomerById(id);

        return ResponseEntity.ok(
                ApiResponse.success("Customer fetched successfully", response)
        );
    }

}
