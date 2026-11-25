package com.code.monks.csm.dto.ledger;

import java.math.BigInteger;

public interface PendingReceivedAmountView {
    Integer getCustomerId();
    Integer getSupplierId();
    BigInteger getAmount();
}

