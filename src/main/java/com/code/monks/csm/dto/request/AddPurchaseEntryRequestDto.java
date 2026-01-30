package com.code.monks.csm.dto.request;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class AddPurchaseEntryRequestDto {
    private LocalDate date;
    private int staffId;
    private int supplierId;
    private List<Integer> customerIds;
    private Double purchaseAmount;
}
