package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.ApiResponse;
import com.code.monks.csm.dto.ledger.LedgerResponseDto;
import com.code.monks.csm.enums.LedgerViewTypeEnum;
import com.code.monks.csm.service.LedgerExcelService;
import com.code.monks.csm.service.LedgerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static com.code.monks.csm.constants.ApiPaths.*;

@RestController
@RequestMapping(BASE)
@RequiredArgsConstructor
public class LedgerController {

    private final LedgerService ledgerService;
    private final LedgerExcelService ledgerExcelService;

    @GetMapping(LEDGER)
    public ResponseEntity<ApiResponse<LedgerResponseDto>> getLedger(
            @RequestParam Integer supplierId,
            @RequestParam Integer customerId,
            @RequestParam LedgerViewTypeEnum viewType) {

        LedgerResponseDto response = ledgerService.getLedger(supplierId, customerId, viewType);
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Ledger fetched successfully",
                        response
                )
        );
    }

    @GetMapping(LEDGER_DOWNLOAD)
    public ResponseEntity<byte[]> downloadLedgerExcel(
            @RequestParam Integer supplierId,
            @RequestParam Integer customerId,
            @RequestParam LedgerViewTypeEnum viewType
    ) {

        LedgerResponseDto ledger = ledgerService.getLedger(supplierId, customerId, viewType);
        byte[] excel = ledgerExcelService.generateExcel(ledger);
        String filename = String.format("ledger_%s.xlsx", ledger.party().name().replaceAll("\\s+", "_"));
        return ResponseEntity.ok()
                .header(
                        HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=" + filename
                )
                .contentType(
                        MediaType.parseMediaType(
                                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                        )
                )
                .body(excel);
    }
}
