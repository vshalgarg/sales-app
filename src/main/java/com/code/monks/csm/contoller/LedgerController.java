package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.ApiResponse;
import com.code.monks.csm.dto.ledger.LedgerResponseDto;
import com.code.monks.csm.enums.LedgerViewTypeEnum;
import com.code.monks.csm.service.LedgerService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import static com.code.monks.csm.constants.ApiPaths.BASE;
import static com.code.monks.csm.constants.ApiPaths.LEDGER;

@RestController
@RequestMapping(BASE)
@RequiredArgsConstructor
public class LedgerController {

    private final LedgerService ledgerService;

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
}
