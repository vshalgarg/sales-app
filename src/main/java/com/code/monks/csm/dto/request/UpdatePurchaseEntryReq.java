package com.code.monks.csm.dto.request;

import lombok.Data;

import java.time.LocalDate;

@Data
public class UpdatePurchaseEntryReq {

    private LocalDate date;
    private Integer staffId;
    private Integer supplierId;
    private Integer customerId;
    private long purchaseAmount;
}
