package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.ApiResponse;
import com.code.monks.csm.dto.request.CreateRetailerRequestDto;
import com.code.monks.csm.dto.request.RetailSupplierDepositRequestDto;
import com.code.monks.csm.dto.request.UpdateRetailSupplierRequestDto;
import com.code.monks.csm.dto.request.UpdateRetailerRequestDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.RetailResponseDto;
import com.code.monks.csm.dto.response.RetailerListResponseDto;
import com.code.monks.csm.dto.response.SupplierDepositHistoryResponseDto;
import com.code.monks.csm.repository.RetailRepository;
import com.code.monks.csm.service.RetailService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

import static com.code.monks.csm.constants.ApiPaths.*;

@RequestMapping(BASE)
@RestController
@RequiredArgsConstructor
@Slf4j
public class RetailController {
    private final RetailRepository retailRepository;

    private final RetailService retailService;

    @PostMapping(ADD_RETAILER)
    public ResponseEntity<ApiResponse<Void>> createRetail(
           @Valid @RequestBody CreateRetailerRequestDto request
    ) {

        retailService.createRetail(request);
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Retail created successfully"
                )
        );
    }

    @PutMapping(UPDATE_RETAILER)
    public ResponseEntity<ApiResponse<Void>> updateRetail(
            @PathVariable Long id,
           @Valid @RequestBody UpdateRetailerRequestDto request
    ) {
        retailService.updateRetail(id, request);
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Retail updated successfully"
                )
        );
    }

    @GetMapping(GET_RETAILER)
    public ResponseEntity<ApiResponse<RetailResponseDto>> getRetailDetails(@PathVariable Long id) {

        var response = retailService.getRetailDetails(id);
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Retail fetched successfully",
                        response
                )
        );
    }

    @GetMapping(SEARCH_RETAILERS)
    public ResponseEntity<ApiResponse<PagedResponseDto<RetailerListResponseDto>>> searchRetailers(

            @RequestParam(required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd")
            LocalDate fromDate,

            @RequestParam(required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd")
            LocalDate toDate,

            @RequestParam(required = false)
            Integer customerId,

            @RequestParam(required = false)
            Integer staffId,

            @RequestParam(required = false)
            Integer supplierId,

            @RequestParam(defaultValue = "0")
            int page,

            @RequestParam(defaultValue = "10")
            int size
    ) {

        log.info(
                "Search Retailers customerId={}, staffId={}, supplierId={}, page={}, size={}",
                customerId,
                staffId,
                supplierId,
                page,
                size
        );

        var response =  retailService.searchRetailers(
                fromDate,
                toDate,
                customerId,
                staffId,
                supplierId,
                page,
                size
        );

        return ResponseEntity.ok(
                ApiResponse.success(
                        "Retail fetched successfully",
                        response
                )
        );
    }

    @PostMapping(ADD_DEPOSIT)
    public ResponseEntity<ApiResponse<Void>> addDeposit(
            @Valid @RequestBody RetailSupplierDepositRequestDto request
    ) {
        retailService.addDeposit(request);
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Add Deposit successfully",
                       null
                )
        );
    }

    @GetMapping(GET_DEPOSIT_HISTORY)
    public ResponseEntity<ApiResponse<List<SupplierDepositHistoryResponseDto>>> getDepositHistory(
            @PathVariable Long retailId
    ) {

        return ResponseEntity.ok(
                ApiResponse.success(
                "Deposit history fetched successfully",
                        retailService.getDepositHistory(retailId)
                )
        );
    }

    @DeleteMapping(DELETE_RETAILER)
    public ApiResponse<String> deleteRetailer(@PathVariable Long retailId) {

        retailService.deleteRetailer(retailId);
        return ApiResponse.success(
                "Retail deleted successfully",null
        );
    }

    @PutMapping(UPDATE_RETAIL_SUPPLIER)
    public ResponseEntity<ApiResponse<Void>> updateRetailSupplier(
            @PathVariable Long retailId,
            @PathVariable Integer retailSupplierId,
            @Valid @RequestBody UpdateRetailSupplierRequestDto request
    ) {

        retailService.updateRetailSupplier(
                retailId,
                retailSupplierId,
                request
        );

        return ResponseEntity.ok(
                ApiResponse.success(
                        "Retail supplier updated successfully"
                )
        );
    }

    @DeleteMapping(DELETE_RETAIL_SUPPLIER)
    public ResponseEntity<ApiResponse<Void>> deleteRetailSupplier(
            @PathVariable Long retailId,
            @PathVariable Integer retailSupplierId
    ) {

        retailService.deleteRetailSupplier(
                retailId,
                retailSupplierId
        );

        return ResponseEntity.ok(
                ApiResponse.success(
                        "Retail supplier deleted successfully"
                )
        );
    }
}
