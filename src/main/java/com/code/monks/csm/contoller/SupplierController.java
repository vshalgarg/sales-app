package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.ApiResponse;
import com.code.monks.csm.dto.request.AddSupplierRequestDto;
import com.code.monks.csm.dto.request.DeleteSupplierRequestDto;
import com.code.monks.csm.dto.request.UpdateSupplierRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.SupplierService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.code.monks.csm.constants.ApiPaths.*;

@RequestMapping(BASE)
@AllArgsConstructor
@RestController
@Slf4j
public class SupplierController {

     private final SupplierService supplierService;

     @PostMapping(ADD_SUPPLIER)
     public ResponseEntity<AddSupplierResponseDto> addSupplier(
          @Valid @RequestBody AddSupplierRequestDto requestDto) {
    log.info("POST {} called to add supplier with name: {}", ADD_SUPPLIER, requestDto.getSupplierName());

    AddSupplierResponseDto response = supplierService.addSupplier(requestDto);

    log.info("Supplier '{}' added successfully", requestDto.getSupplierName());
    return ResponseEntity.ok(response);
  }

  @GetMapping(GET_SUPPLIERS)
  public ResponseEntity<PagedResponseDto<GetSuppliersDto>> getSuppliers(
          @RequestParam(defaultValue = "0") int page,
          @RequestParam(defaultValue = "8") int size
  ) {
    log.info("GET {} called to retrieve suppliers", GET_SUPPLIERS);

      PagedResponseDto<GetSuppliersDto> response = supplierService.getSuppliers(page, size);

    log.info("Retrieved {} suppliers successfully", response.getContent().size());
    return ResponseEntity.ok(response);
  }

    @GetMapping(GET_SUPPLIERS_V2)
    public ResponseEntity<List<GetSuppliersDto>> getAllSuppliers(
    ) {
        log.info("GET {} called to retrieve suppliers.", GET_SUPPLIERS);

        List<GetSuppliersDto> response = supplierService.getAllSuppliers();

        log.info("Retrieved {} suppliers successfully.", response.size());
        return ResponseEntity.ok(response);
    }

  @PutMapping(DELETE_SUPPLIER)
  public ResponseEntity<DeleteSupplierResponseDto> deleteSupplier(
          @Valid @RequestBody DeleteSupplierRequestDto requestDto) {
    log.info("PUT {} called to delete supplier with ID: {}", DELETE_SUPPLIER, requestDto.getCode());

    DeleteSupplierResponseDto response = supplierService.deleteSupplier(requestDto);

    log.info("Supplier with ID {} deleted successfully", requestDto.getCode());
    return ResponseEntity.ok(response);
  }

      @GetMapping(SEARCH_SUPPLIERS_V2)
      public ResponseEntity<Page<SearchSuppliersResponseDto>> searchSuppliers(
              @RequestParam(required = false) String keyword,
              @RequestParam(defaultValue = "0") int page,
              @RequestParam(defaultValue = "10") int size,
              @RequestParam(defaultValue = "supplierName") String sortBy,
              @RequestParam(defaultValue = "asc") String sortDir

      ){
          Pageable pageable = PageRequest.of(page, size,
                  Sort.Direction.fromString(sortDir), sortBy);
          Page<SearchSuppliersResponseDto> response = supplierService.searchSuppliers(keyword, pageable);
          return ResponseEntity.ok(response);
      }

    @GetMapping(SEARCH_SUPPLIERS)
    public ResponseEntity<List<SearchSuppliersResponseDto>> searchSuppliers(@RequestParam String keyword){
        List<SearchSuppliersResponseDto> response = supplierService.searchSuppliers(keyword);
        return ResponseEntity.ok(response);
    }

    @PutMapping(UPDATE_SUPPLIER)
    public ResponseEntity<ApiResponse<?>> update(
            @PathVariable Integer id,
            @RequestBody UpdateSupplierRequestDto request) {

        supplierService.updateSupplier(id, request);

        return ResponseEntity.ok(
                ApiResponse.success("Supplier updated successfully")
        );
    }

    @GetMapping(GET_SUPPLIER_BY_ID)
    public ResponseEntity<ApiResponse<GetSupplierByIdResponseDto>> getSupplierById(
            @PathVariable Integer id) {

        log.info("GET supplier by id={} called", id);

        GetSupplierByIdResponseDto response =
                supplierService.getSupplierById(id);

        return ResponseEntity.ok(
                ApiResponse.success("Supplier fetched successfully", response)
        );
    }

}
