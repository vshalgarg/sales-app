package com.code.monks.csm.common;

import java.math.BigDecimal;

public interface BillItemCommon {

    int getPieces();
    BigDecimal getGrossAmount();
    BigDecimal getDiscountAmount();
    BigDecimal getAddOnAmount();
    BigDecimal getEcrAmount();
    BigDecimal getGstAmount();
    BigDecimal getDiscountPercent();
    BigDecimal getGstPercent();
}
