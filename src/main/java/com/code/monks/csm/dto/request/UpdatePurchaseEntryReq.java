package com.code.monks.csm.dto.request;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class UpdatePurchaseEntryReq {

    private LocalDate date;
    private Integer staffId;
    private Integer customerId;
    private Integer supplierId;
    private String remarks;

    private List<String> existingImageKeys;
}
