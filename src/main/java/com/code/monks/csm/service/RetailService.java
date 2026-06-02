package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.RetailRequestDto;
import com.code.monks.csm.dto.response.RetailResponseDto;

public interface RetailService {
    void createRetail(RetailRequestDto request);
    void updateRetail(Long retailId, RetailRequestDto request);
    RetailResponseDto getRetailDetails(Long retailId);
}
