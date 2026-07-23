package com.code.monks.csm.dto.response;

import com.code.monks.csm.enums.CreditEntryEnum;
import com.code.monks.csm.enums.DrawTypeEnum;

import java.time.LocalDate;

public record CreditDetailResponse(
        int id,
        CreditEntryEnum paymentType,
        String billNumber,
        LocalDate date,
        String referenceNumber,
        LocalDate referenceDate,
        Double receivedAmount,
        DrawTypeEnum drawType,
        String remark,
        String slipNumber,
        int supplierId,
        String supplierName,
        String supplierCity,
        int customerId,
        String customerName,
        String customerCity
) {
}
