package com.code.monks.csm.dto.request;


import com.code.monks.csm.common.BillItemCommon;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class BillItemRequestDto implements BillItemCommon {
    private int pieces;
    private BigDecimal discountPercent;
    private BigDecimal gstPercent;
    private BigDecimal grossAmount;
    private BigDecimal discountAmount;
    private BigDecimal addOnAmount;
    private BigDecimal ecrAmount;
    private BigDecimal gstAmount;
}
