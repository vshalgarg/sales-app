package com.code.monks.csm.utils;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class MoneyUtil {

    private static final BigDecimal HUNDRED = BigDecimal.valueOf(100);

    public static long toPaisa(BigDecimal amount) {
        if (amount == null) return 0L;
        return amount
                .multiply(HUNDRED)
                .setScale(0, RoundingMode.HALF_UP)
                .longValue();
    }

    public static BigInteger toPaisaBigInteger(BigDecimal amount) {
        if (amount == null) return BigInteger.ZERO;
        return amount.multiply(HUNDRED)
                .setScale(0, RoundingMode.HALF_UP)
                .toBigInteger();
    }

    public static BigDecimal toRupee(Long paisa) {
        if (paisa == null) {
            return null;
        }
        return BigDecimal.valueOf(paisa)
                .divide(HUNDRED, 2, RoundingMode.HALF_UP);
    }

    public static int percentToBasisPoint(BigDecimal percent) {
        if (percent == null) return 0;
        return percent
                .multiply(BigDecimal.valueOf(100))
                .setScale(0, RoundingMode.HALF_UP)
                .intValue();
    }

    public static BigDecimal basisPointToPercent(int value) {
        return BigDecimal.valueOf(value)
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
    }

    public static BigDecimal roundToNearestInteger(BigDecimal amount) {
        if (amount == null) return BigDecimal.ZERO;
        return amount.setScale(0, RoundingMode.HALF_UP);
    }
}
