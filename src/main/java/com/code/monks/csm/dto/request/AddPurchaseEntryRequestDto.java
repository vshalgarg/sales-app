package com.code.monks.csm.dto.request;

import lombok.Data;

import java.time.LocalDate;

@Data
public class AddPurchaseEntryRequestDto {
    private LocalDate date;
    private int staffId;
    private int supplierId;
    private int customerId;
    private double purchaseAmount;
}
