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
    private Integer supplierId;
    private List<Integer> customerIds;
    private List<String> customerNames;
    private Integer staffId;
    private double purchaseAmount;

}
