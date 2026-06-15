package com.code.monks.csm.dto.analytics.projection;

public interface MonthlyAnalyticsView {

    Integer getYear();
    Integer getMonth();
    Long getAmount();
    Long getCount();
}