package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class BillItemDto {

    private int pieces;
    private double grossAmount;
    private int discountPercent;
    private double discountAmount;
    private double addOnAmount;
    private double ecrAmount;
    private int gstPercent;
    private double gstAmount;
}
