package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class SearchBillEntryResponse {
    private String billNumber;
    private LocalDate date;
    private LocalDate receivedDate;
    private String order;
    private int pieces;
    private double grossAmount;
    private float discountPercent;
    private double discountAmount;
    private float gstPercent;
    private double gstAmount;
    private double billAmount;
    private double addOnAmount;
    private double taxableValue;
    private Integer supplierId;
    private String supplierName;
    private String supplierGroup;
    private String supplierGstNo;
    private String supplierMsme;
    private Integer customerId;
    private String customerName;
    private String customerGroup;
    private String customerGstNo;
    private String customerMsme;
    private double ecrAmount;
    private String transport;
    private String lrNumber;
    private String remarks;
}
