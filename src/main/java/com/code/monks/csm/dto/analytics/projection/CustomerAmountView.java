package com.code.monks.csm.dto.analytics.projection;

import java.math.BigInteger;

public interface CustomerAmountView {

    Integer getCustomerId();
    BigInteger getAmount();
}
