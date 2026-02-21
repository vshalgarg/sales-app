package com.code.monks.csm.dto.request;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class UpdatePurchaseEntryReq {

    private LocalDate date;
    private Integer staffId;
    private List<Integer> supplierIds;
    private Integer customerId;
    private double purchaseAmount;
}
