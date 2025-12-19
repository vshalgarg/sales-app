package com.code.monks.csm.dto.response;

import com.code.monks.csm.entity.BillDetailEntity;
import com.code.monks.csm.entity.BillEntryEntity;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

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
        List<BillDetailEntity> details = bill.getBillDetails();
        boolean hasDetails = !details.isEmpty();

        // Aggregate from details
        int pieces = hasDetails ? details.stream().mapToInt(BillDetailEntity::getPieces).sum() : 0;
        double grossAmount = hasDetails ? details.stream().mapToDouble(BillDetailEntity::getGrossAmount).sum() / 100.0 : 0.0;
        double discountAmount = hasDetails ? details.stream().mapToDouble(BillDetailEntity::getDiscountAmount).sum() / 100.0 : 0.0;
        double addOnAmount = hasDetails ? details.stream().mapToDouble(BillDetailEntity::getAddOnAmount).sum() / 100.0 : 0.0;
        double ecrAmount = hasDetails ? details.stream().mapToDouble(BillDetailEntity::getEcrAmount).sum() : 0.0;  // No /100 in original for ecr
        double gstAmount = hasDetails ? details.stream().mapToDouble(BillDetailEntity::getGstAmount).sum() / 100.0 : 0.0;

        // Percentages: Take from first (assume uniform)
        float discountPercent = hasDetails ? details.get(0).getDiscountPercent() / 100.0f : 0.0f;
        float gstPercent = hasDetails ? details.get(0).getGstPercent() / 100.0f : 0.0f;

        return GetBillEntries.builder()
                .billNumber(bill.getBillNumber())
                .date(bill.getDate())
                .receivedDate(bill.getReceivedDate())
                .order(bill.getOrders())
                .pieces(pieces)
                .grossAmount(grossAmount)
                .discountPercent(discountPercent)
                .discountAmount(discountAmount)
                .gstPercent(gstPercent)
                .gstAmount(gstAmount)
                .billAmount(bill.getBillAmount() / 100.0)
                .addOnAmount(addOnAmount)
                .taxableValue(bill.getTaxableValue() / 100.0)
                .supplierId(bill.getSupplierId())
                .customerId(bill.getCustomerId())
                .ecrAmount(ecrAmount)
                .transport(bill.getTransportEntity().getName())
                .lrNumber(bill.getLrNumber())
                .remarks(bill.getRemarks())
                .build();
    }
}
