package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.BillEntryRequestDto;
import com.code.monks.csm.dto.request.BillUpdateRequest;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.BillService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import static com.code.monks.csm.constants.ApiPaths.*;

@RequestMapping(BASE)
@RestController
@AllArgsConstructor
@Slf4j
public class BillEntryController {

    private final BillService billService;

    @PostMapping(ADD_BILL)
    public ResponseEntity<BillEntryResponseDto> addBill(@Valid @RequestBody BillEntryRequestDto requestDto) {
        log.info("Received request to add bill: {}", requestDto);

        BillEntryResponseDto response = billService.addBill(requestDto);

        log.info("Bill added successfully. Response: {}", response);

        return ResponseEntity.ok(response);
    }

    @GetMapping(GET_BILL_ENTRIES)
    public ResponseEntity<List<GetBillEntries>> getBillEntries() {
        log.info("Received request to get all bill entries");

        List<GetBillEntries> billEntries = billService.getBillEntries();

        log.info("Fetched {} bill entries", billEntries.size());

        return ResponseEntity.ok(billEntries);
    }


    @PatchMapping(UPDATE_BILL_ENTRY)
    public ResponseEntity<EditBillEntryResponse> updateBill(
            @PathVariable String billNumber,
            @RequestBody BillUpdateRequest request) {

        EditBillEntryResponse response = billService.updateBill(billNumber, request);
        return ResponseEntity.ok(response);
    }

    @GetMapping(SEARCH_BILL_ENTRY)
    public ResponseEntity<PagedResponseDto<SearchBillEntryResponse>> getBillHistory(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate fromDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate toDate,
            @RequestParam(required = false) Integer supplierId,
            @RequestParam(required = false) Integer customerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "7") int size) {

        // Validate that both dates are present
        if (fromDate == null || toDate == null) {
            return ResponseEntity.badRequest().build();
        }

        PagedResponseDto<SearchBillEntryResponse> history = billService.searchBillHistory(
                fromDate,
                toDate,
                supplierId,
                customerId,
                page,
                size
        );

        return ResponseEntity.ok(history);
    }

}
