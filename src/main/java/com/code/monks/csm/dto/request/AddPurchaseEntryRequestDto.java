package com.code.monks.csm.dto.request;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class AddPurchaseEntryRequestDto {
    private LocalDate date;
    private int staffId;
    private List<Integer> supplierIds;
    private Integer customerId;
    private Double purchaseAmount;
}
