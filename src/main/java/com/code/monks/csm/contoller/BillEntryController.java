package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.BillEntryRequestDto;
import com.code.monks.csm.dto.request.BillUpdateRequest;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.BillService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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

    @PostMapping(
            value = ADD_BILL,
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<BillEntryResponseDto> addBill(
            @Valid
            @RequestPart("payload") BillEntryRequestDto requestDto,

            @RequestPart(value = "images", required = false)
            List<MultipartFile> images

    ) {
        log.info("Received request to add bill: {}", requestDto);

        BillEntryResponseDto response = billService.addBill(requestDto, images);

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


    @PatchMapping(
            value = UPDATE_BILL_ENTRY,
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<EditBillEntryResponse> updateBill(
            @PathVariable String billNumber,
            @RequestPart("data") BillUpdateRequest request,
            @RequestPart(value = "images", required = false)
            List<MultipartFile> images
    ) {

        EditBillEntryResponse response =
                billService.updateBill(billNumber, request, images);

        return ResponseEntity.ok(response);
    }

    @GetMapping(SEARCH_BILL_ENTRY)
    public ResponseEntity<PagedResponseDto<SearchBillEntryResponse>> getBillHistory(
            @RequestParam(required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd")
            LocalDate fromDate,

            @RequestParam(required = false)
            @DateTimeFormat(pattern = "yyyy-MM-dd")
            LocalDate toDate,

            @RequestParam(required = false) Integer supplierId,
            @RequestParam(required = false) Integer customerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "7") int size) {

        if (fromDate == null && toDate == null && supplierId == null && customerId == null) {
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

    @DeleteMapping(DELETE_BILL_ENTRY + "/{billNumber}")
    public ResponseEntity<Map<String, Object>> deleteBillEntry( @PathVariable String billNumber){

       Map<String, Object> response = billService.deleteBillEntry(billNumber);
       return new ResponseEntity<>(response, HttpStatus.OK);
    }

}
