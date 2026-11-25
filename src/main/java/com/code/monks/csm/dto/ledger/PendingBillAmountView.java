package com.code.monks.csm.dto.ledger;

import java.math.BigInteger;

public interface PendingBillAmountView {
    Integer getCustomerId();
    String getCustomerName();
    Integer getSupplierId();
    String getSupplierName();
    BigInteger getAmount();
}

