package com.code.monks.csm.dto.response;

import com.code.monks.csm.common.BillItemCommon;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

@Data
@Builder
public class BillItemDto implements BillItemCommon {

    private int pieces;
    private BigDecimal discountPercent;
    private BigDecimal gstPercent;
    private BigDecimal grossAmount;
    private BigDecimal discountAmount;
    private BigDecimal addOnAmount;
    private BigDecimal ecrAmount;
    private BigDecimal gstAmount;
}
