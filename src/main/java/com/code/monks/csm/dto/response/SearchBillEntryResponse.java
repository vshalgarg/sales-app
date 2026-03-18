package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
public class SearchBillEntryResponse {
    private String billNumber;
    private LocalDate date;
    private LocalDate receivedDate;
    private String invoiceNo;
    private String supplierName;
    private String customerName;
    private BigDecimal billAmount;
    private BigDecimal taxableValue;

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

    public List<String> objectKeys;
    private List<String> publicUrls;
}
