package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
@Builder
public class SearchBillEntryResponse {
    private String billNumber;
    private LocalDate date;
    private LocalDate receivedDate;
    private String order;
    private String supplierName;
    private String customerName;
    private double billAmount;
    private double taxableValue;

    private Integer supplierId;
    private String supplierGroup;
    private String supplierGstNo;
    private String supplierMsme;
    private Integer customerId;
    private String customerGroup;
    private String customerGstNo;
    private String customerMsme;

    private String transport;
    private String lrNumber;
    private String remarks;

    private List<BillItemDto> items;
}
