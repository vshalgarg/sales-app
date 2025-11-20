package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.dto.response.AddPurchaseEntryResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.SearchPurchaseEntryResponse;
import com.code.monks.csm.service.PurchaseService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

import static com.code.monks.csm.constants.ApiPaths.*;

@Slf4j
@RequestMapping(BASE)
@RestController
public class PurchaseEntryController {

    private final PurchaseService purchaseService;

    public PurchaseEntryController(PurchaseService purchaseService) {
        this.purchaseService = purchaseService;
    }

    @PostMapping(ADD_PURCHASE_ENTRY)
    public ResponseEntity<AddPurchaseEntryResponseDto> addPurchaseEntry(@RequestBody AddPurchaseEntryRequestDto requestDto){
        AddPurchaseEntryResponseDto response = purchaseService.addPurchaseEntry(requestDto);
        return ResponseEntity.ok(response);
    }

    @GetMapping(SEARCH_PURCHASE_ENTRIES)
    public ResponseEntity<PagedResponseDto<SearchPurchaseEntryResponse>> getPurchaseHistory(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate fromDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate toDate,
            @RequestParam(required = false) Integer supplierId,
            @RequestParam(required = false) Integer customerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "7") int size
    ) {
        // 🔹 Log entry point
        log.info("🎯 [GET] /purchase/entries/search called");

        // 🔹 Log request parameters clearly
        log.info("➡️ Received request with parameters: fromDate={}, toDate={}, supplierId={}, customerId={}, page={}, size={}",
                fromDate, toDate, supplierId, customerId, page, size);

        try {
            // 🔹 Log before calling service
            log.debug("🔍 Calling purchaseService.searchPurchaseHistory()...");

            PagedResponseDto<SearchPurchaseEntryResponse> history =
                    purchaseService.searchPurchaseHistory(fromDate, toDate, supplierId, customerId, page, size);

            // 🔹 Log after success
            log.info("✅ Successfully fetched purchase history. Records fetched: {} | Current Page: {} | Total Pages: {}",
                    history.getTotalElements(), history.getPage(), history.getTotalPages());

            return ResponseEntity.ok(history);

        } catch (Exception e) {
            // 🔹 Log if something goes wrong
            log.error("❌ Error fetching purchase history: {}", e.getMessage(), e);
            throw e; // or return ResponseEntity.internalServerError().build();
        }
    }

}
