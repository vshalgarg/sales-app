package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
public class SearchPurchaseEntryResponse {
    private int id;

    private LocalDate date;

    private String staffName;

    private List<String> supplierNames;

    private String customerName;

    private String remarks;

}
