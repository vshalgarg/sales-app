package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.ApiResponse;
import com.code.monks.csm.dto.purchase.PurchaseDetailResponse;
import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.dto.request.CopySupplierDetailsRequest;
import com.code.monks.csm.dto.request.UpdatePurchaseEntryReq;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.PurchaseExcelService;
import com.code.monks.csm.service.PurchaseService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.MultiValueMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import static com.code.monks.csm.constants.ApiPaths.*;

@Slf4j
@RequestMapping(BASE)
@RestController
public class PurchaseEntryController {

    private final PurchaseService purchaseService;
    private final PurchaseExcelService purchaseExcelService;

    public PurchaseEntryController(PurchaseService purchaseService, PurchaseExcelService purchaseExcelService) {
        this.purchaseService = purchaseService;
        this.purchaseExcelService = purchaseExcelService;
    }

    @PostMapping(
            value = ADD_PURCHASE_ENTRY,
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<AddPurchaseEntryResponseDto> addPurchaseEntry(
            @RequestPart("payload") AddPurchaseEntryRequestDto requestDto,
            @RequestParam(required = false) MultiValueMap<String, MultipartFile> supplierImages
    ){
        AddPurchaseEntryResponseDto response = purchaseService.addPurchaseEntry(requestDto, supplierImages);
        return ResponseEntity.ok(response);
    }

    @GetMapping(SEARCH_PURCHASE_ENTRIES)
    public ResponseEntity<PagedResponseDto<PurchaseHistoryResponseDto>> getPurchaseHistory(
            @RequestParam(required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate fromDate,

            @RequestParam(required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate toDate,

            @RequestParam(required = false) Integer supplierId,
            @RequestParam(required = false) Integer customerId,
            @RequestParam(required = false) Integer staffId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "7") int size
    ) {
        log.info("Purchase search called: fromDate={}, toDate={}, supplierId={}, customerId={}",
                fromDate, toDate, supplierId, customerId);

        return ResponseEntity.ok(
                purchaseService.searchPurchaseHistory(
                        fromDate, toDate, supplierId, customerId, staffId, page, size
                )
        );
    }

    @PatchMapping(value = UPDATE_PURCHASE_ENTRY, consumes = "multipart/form-data")
    public ResponseEntity<Map<String, Object>> updatePurchaseEntry(
            @PathVariable int id,
            @RequestPart("data") UpdatePurchaseEntryReq req,
            @RequestParam(required = false) MultiValueMap<String, MultipartFile> supplierImages
    ) {
        Map<String, Object> response =
                purchaseService.updatePurchaseEntry(id, req, supplierImages);

        return ResponseEntity.ok(response);
    }

    @DeleteMapping(DELETE_PURCHASE_ENTRY)
    public ResponseEntity<Map<String, Object>> deletePurchaseEntry(@PathVariable int id){
       Map<String, Object> response = purchaseService.deletePurchaseEntry(id);
       return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping(GET_PURCHASE_DETAILS_BY_ID)
    public ResponseEntity<ApiResponse<PurchaseDetailResponse>> getPurchaseById(
            @PathVariable int id
    ) {
        PurchaseDetailResponse response =
                purchaseService.getPurchaseById(id);
        return ResponseEntity.ok(
                ApiResponse.success("Purchase details fetched successfully", response)
        );
    }

    @PostMapping(GET_COPY_SUPPLIER_DETAILS_PER_CUSTOMER)
    public ResponseEntity<ApiResponse<CopySupplierDetailsResponseDTO>> copySupplierDetails(
           @RequestBody CopySupplierDetailsRequest request) {

        CopySupplierDetailsResponseDTO response = purchaseService.copySupplierDetailsPerCustomer(request);
        return ResponseEntity.ok(
                ApiResponse.success("Copy Supplier Details PerCustomer fetched successfully", response)
        );
    }

    @PostMapping(DOWNLOAD_PURCHASE_HISTORY)
    public ResponseEntity<byte[]> downloadPurchaseHistory(
            @RequestParam(required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate fromDate,

            @RequestParam(required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate toDate,

            @RequestParam(required = false) Integer supplierId,
            @RequestParam(required = false) Integer customerId,
            @RequestParam(required = false) Integer staffId
    ) {
        log.info("Purchase history download called: fromDate={}, toDate={}, supplierId={}, customerId={}",
                fromDate, toDate, supplierId, customerId);

        List<PurchaseHistoryResponseDto> entries = purchaseService.downloadPurchaseHistory(
                fromDate, toDate, supplierId, customerId, staffId
        );
        byte[] excel = purchaseExcelService.generateExcel(entries, fromDate, toDate);
        String filename = purchaseExcelService.buildPurchaseExcelFilename(entries, fromDate, toDate);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename)
                .contentType(MediaType.parseMediaType(
                        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"))
                .body(excel);
    }

}
