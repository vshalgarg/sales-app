package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.dto.request.UpdatePurchaseEntryReq;
import com.code.monks.csm.dto.response.AddPurchaseEntryResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.SearchPurchaseEntryResponse;
import com.code.monks.csm.service.PurchaseService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;

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
            @RequestParam(required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate fromDate,

            @RequestParam(required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate toDate,

            @RequestParam(required = false) Integer supplierId,
            @RequestParam(required = false) Integer customerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "7") int size
    ) {
        log.info("Purchase search called: fromDate={}, toDate={}, supplierId={}, customerId={}",
                fromDate, toDate, supplierId, customerId);

        return ResponseEntity.ok(
                purchaseService.searchPurchaseHistory(
                        fromDate, toDate, supplierId, customerId, page, size
                )
        );
    }

    @PatchMapping(UPDATE_PURCHASE_ENTRY)
    public ResponseEntity<Map<String, Object>> updatePurchaseEntry(@PathVariable int id,
                                                                   @RequestBody UpdatePurchaseEntryReq updatePurchaseEntryReq
                                                                   ){
       Map<String, Object> response = purchaseService.updatePurchaseEntry(id, updatePurchaseEntryReq);
       return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @DeleteMapping(DELETE_PURCHASE_ENTRY)
    public ResponseEntity<Map<String, Object>> deletePurchaseEntry(@PathVariable int id){
       Map<String, Object> response = purchaseService.deletePurchaseEntry(id);
       return new ResponseEntity<>(response, HttpStatus.OK);
    }

}
