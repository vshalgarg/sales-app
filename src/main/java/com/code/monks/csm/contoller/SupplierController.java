package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.AddSupplierRequestDto;
import com.code.monks.csm.dto.request.DeleteSupplierRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.SupplierService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.annotation.MergedAnnotations;
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
          @RequestParam(defaultValue = "1") int page,
          @RequestParam(defaultValue = "8") int size
  ) {
    log.info("GET {} called to retrieve suppliers", GET_SUPPLIERS);

      PagedResponseDto<GetSuppliersDto> response = supplierService.getSuppliers(page, size);

    log.info("Retrieved {} suppliers successfully", response.getContent().size());
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

      @GetMapping(SEARCH_SUPPLIERS)
      public ResponseEntity<List<SearchSuppliersResponseDto>> searchSuppliers(@RequestParam String keyword){
          List<SearchSuppliersResponseDto> response = supplierService.searchSuppliers(keyword);
          return ResponseEntity.ok(response);
      }

}
