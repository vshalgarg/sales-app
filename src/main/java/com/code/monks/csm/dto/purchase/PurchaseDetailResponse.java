package com.code.monks.csm.dto.purchase;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class PurchaseDetailResponse {

    private int id;

    private LocalDate date;

    private Integer staffId;
    private String staffName;

    private Integer customerId;
    private String customerName;

    private String remarks;

    private SupplierPurchaseDetailDto supplier;
}