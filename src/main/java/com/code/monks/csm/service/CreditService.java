package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.AddCreditEntryRequestDto;
import com.code.monks.csm.dto.response.*;

import java.time.LocalDate;
import java.util.List;

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
}
