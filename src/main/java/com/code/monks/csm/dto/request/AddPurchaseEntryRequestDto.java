package com.code.monks.csm.dto.request;

import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class AddPurchaseEntryRequestDto {
    private LocalDate date;
    private Integer staffId;
    private Integer customerId;
    private List<SupplierPurchaseDto> suppliers;
}
