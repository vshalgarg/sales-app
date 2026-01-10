package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.AddCreditEntryRequestDto;
import com.code.monks.csm.dto.request.CreditUpdateRequest;
import com.code.monks.csm.dto.response.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

public interface CreditService {
    AddCreditEntryResponseDto addCreditEntry(AddCreditEntryRequestDto requestDto);
    List<GetCreditEntries> getCreditEntries();
    PagedResponseDto<SearchCreditEntryResponse> searchCreditHistory(
            LocalDate fromDate,
            LocalDate toDate,
            Integer supplierId,
            Integer customerId,
            int page,
            int size);

    Map<String, Object> deleteCreditEntry(int id);
    Map<String, Object> updateCreditEntry(int id, CreditUpdateRequest request);
}
