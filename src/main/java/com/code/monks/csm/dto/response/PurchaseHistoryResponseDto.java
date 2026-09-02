package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class PurchaseHistoryResponseDto {
    private int id;

    private LocalDate date;

    private String staffName;

    private String supplierName;

    private String customerName;

    private String remarks;
    private String customerCity;
    private String supplierCity;
    private Integer customerId;

}
