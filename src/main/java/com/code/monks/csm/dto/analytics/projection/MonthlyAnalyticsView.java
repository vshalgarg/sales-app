package com.code.monks.csm.dto.analytics.projection;

import java.math.BigInteger;

public interface MonthlyAnalyticsView {

    Integer getYear();
    Integer getMonth();
    BigInteger getAmount();
    Long getCount();
}