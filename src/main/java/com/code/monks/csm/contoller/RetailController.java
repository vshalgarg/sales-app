package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.ApiResponse;
import com.code.monks.csm.dto.request.RetailRequestDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.RetailResponseDto;
import com.code.monks.csm.dto.response.RetailerListResponseDto;
import com.code.monks.csm.service.RetailService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

import static com.code.monks.csm.constants.ApiPaths.*;

@RequestMapping(BASE)
@RestController
@RequiredArgsConstructor
@Slf4j
public class RetailController {

    private final RetailService retailService;

    @PostMapping(ADD_RETAILER)
    public ResponseEntity<ApiResponse<Void>> createRetail(
           @Valid @RequestBody RetailRequestDto request
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
           @Valid @RequestBody RetailRequestDto request
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
}
