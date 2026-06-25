package com.code.monks.csm.dto.analytics;

public enum MetricType {

    BILL_AMOUNT("Bill Amount", "₹") {
        @Override public Object extract(MonthlyDataPoint d) { return d.billAmount(); }
    },
    CREDIT_AMOUNT("Credit Amount", "₹") {
        @Override public Object extract(MonthlyDataPoint d) { return d.creditAmount(); }
    },
    BILL_COUNT("Bill Count", "COUNT") {
        @Override public Object extract(MonthlyDataPoint d) { return d.billCount(); }
    },
    CREDIT_COUNT("Credit Count", "COUNT") {
        @Override public Object extract(MonthlyDataPoint d) { return d.creditCount(); }
    };

    private final String label;
    private final String unit;

    MetricType(String label, String unit) {
        this.label = label;
        this.unit = unit;
    }

    public abstract Object extract(MonthlyDataPoint d);

    public String getLabel() { return label; }
    public String getUnit() { return unit; }
}
