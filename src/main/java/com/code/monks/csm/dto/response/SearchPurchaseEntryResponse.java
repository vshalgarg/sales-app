package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class SearchPurchaseEntryResponse {
    private int id;
    private LocalDate date;
    private String staffName;
    private String supplierName;
    private String customerName;
    private double purchaseAmount;
    private Integer supplierId;
    private Integer customerId;
    private Integer staffId;

}
