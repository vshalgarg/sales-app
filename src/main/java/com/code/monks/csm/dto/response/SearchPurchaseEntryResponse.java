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

    private Integer staffId;
    private String staffName;
    private List<Integer> supplierIds;
    private List<String> supplierNames;
    private Integer customerId;
    private String customerName;
    private List<String> publicUrls;

    private double purchaseAmount;

}
