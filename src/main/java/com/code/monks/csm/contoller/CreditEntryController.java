package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.AddCreditEntryRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.CreditService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

import static com.code.monks.csm.constants.ApiPaths.*;

@RequestMapping(BASE)
@RestController
@AllArgsConstructor
@Slf4j
public class CreditEntryController {

    private final CreditService creditService;

    @PostMapping(ADD_CREDIT_ENTRY)
    public ResponseEntity<AddCreditEntryResponseDto> addCreditEntry(
            @Valid @RequestBody AddCreditEntryRequestDto requestDto) {

        log.info("Received request to add credit entry: {}", requestDto);

        AddCreditEntryResponseDto response = creditService.addCreditEntry(requestDto);

        log.info("Credit entry added successfully. Response message: {}", response.getMessage());

        return ResponseEntity.ok(response);
    }

    @GetMapping(GET_CREDIT_ENTRIES)
    public ResponseEntity<List<GetCreditEntries>> getCreditEntries() {
        log.info("Received request to fetch all credit entries.");

        List<GetCreditEntries> creditEntriesList = creditService.getCreditEntries();

        log.info("Fetched {} credit entries successfully.", creditEntriesList.size());

        return ResponseEntity.ok(creditEntriesList);
    }

    @GetMapping(SEARCH_CREDIT_ENTRIES)
    public ResponseEntity<PagedResponseDto<SearchCreditEntryResponse>> getCreditHistory(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate fromDate,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate toDate,
            @RequestParam(required = false) Integer supplierId,
            @RequestParam(required = false) Integer customerId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "7") int size
    ){
        PagedResponseDto<SearchCreditEntryResponse> history = creditService.searchCreditHistory(
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
