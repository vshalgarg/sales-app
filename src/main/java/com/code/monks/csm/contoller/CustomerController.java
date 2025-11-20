package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.AddCustomerRequestDto;
import com.code.monks.csm.dto.request.DeleteCustomerRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.CustomerService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
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
    public ResponseEntity<PagedResponseDto<GetCustomersDto>> getCustomers(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "8") int size
    ) {
        log.info("GET customers API called to retrieve customers (page={}, size={})", page, size);

        PagedResponseDto<GetCustomersDto> response = customerService.getCustomers(page, size);
        log.info("Retrieved {} customers successfully", response.getContent().size());

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
    public ResponseEntity<List<SearchCustomersResponseDto>> searchCustomers(@RequestParam String keyword){
        List<SearchCustomersResponseDto> response = customerService.searchCustomers(keyword);
        return ResponseEntity.ok(response);
    }

}
