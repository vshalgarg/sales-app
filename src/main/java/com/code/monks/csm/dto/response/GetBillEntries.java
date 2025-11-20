package com.code.monks.csm.dto.response;

import com.code.monks.csm.entity.BillEntryEntity;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class GetBillEntries {
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
    private int supplierId;
    private String supplierName;
    private String supplierGroup;
    private String supplierGstNo;
    private String supplierMsme;
    private int customerId;
    private String customerName;
    private String customerGroup;
    private String customerGstNo;
    private String customerMsme;
    private double ecrAmount;
    private String transport;
    private String lrNumber;
    private String remarks;

    public static GetBillEntries convertToGetBillEntries(BillEntryEntity bill) {
        return GetBillEntries.builder()
                .billNumber(bill.getBillNumber())
                .date(bill.getDate())
                .receivedDate(bill.getReceivedDate())
                .order(bill.getOrders())
                .pieces(bill.getPieces())
                .grossAmount(bill.getGrossAmount() / 100.0)
                .discountPercent(bill.getDiscountPercent() / 100.0f)
                .discountAmount(bill.getDiscountAmount() / 100.0)
                .gstPercent(bill.getGstPercent() / 100.0f)
                .gstAmount(bill.getGstAmount() / 100.0)
                .billAmount(bill.getBillAmount() / 100.0)
                .addOnAmount(bill.getAddOnAmount() / 100.0)
                .taxableValue(bill.getTaxableValue() / 100.0)
                .supplierId(bill.getSupplierId())
                .customerId(bill.getCustomerId())
                .ecrAmount(bill.getEcrAmount())
                .transport(bill.getTransport())
                .lrNumber(bill.getLrNumber())
                .remarks(bill.getRemarks())
                .build();
    }

}
