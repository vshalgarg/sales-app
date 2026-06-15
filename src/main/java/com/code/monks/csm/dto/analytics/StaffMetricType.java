package com.code.monks.csm.dto.analytics;

public enum StaffMetricType {

    SUPPLIER_COUNT("Supplier Count", "COUNT"),
    CUSTOMER_COUNT("Customer Count", "COUNT"),
    TOTAL_COUNT("Total Count", "COUNT");

    private final String label;
    private final String unit;

    StaffMetricType(String label, String unit) {
        this.label = label;
        this.unit = unit;
    }

    public String getLabel() { return label; }
    public String getUnit() { return unit; }
}
