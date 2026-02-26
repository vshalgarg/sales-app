package com.code.monks.csm.dto.request;


import lombok.Data;

@Data
public class BillItemRequestDto {
    private int pieces;
    private double grossAmount;
    private float discountPercent;
    private double discountAmount;
    private double addOnAmount;
    private double ecrAmount;
    private float gstPercent;
    private double gstAmount;
}
