package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.ApiResponse;
import com.code.monks.csm.dto.request.RetailRequestDto;
import com.code.monks.csm.dto.response.RetailResponseDto;
import com.code.monks.csm.service.RetailService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import static com.code.monks.csm.constants.ApiPaths.*;

@RequestMapping(BASE)
@RestController
@RequiredArgsConstructor
public class RetailController {

    private final RetailService retailService;

    @PostMapping(ADD_RETAILER)
    public ResponseEntity<ApiResponse<Void>> createRetail(
            @RequestBody RetailRequestDto request
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
            @RequestBody RetailRequestDto request
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
}
