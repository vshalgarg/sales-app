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

    private String supplierName;

    private String customerName;

    private String remarks;
    private String customerCity;
    private String supplierCity;

}
