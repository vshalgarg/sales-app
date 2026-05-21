package com.code.monks.csm.dto.response;

import com.code.monks.csm.enums.CreditEntryEnum;
import com.code.monks.csm.enums.DrawTypeEnum;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDate;

@Data
@Builder
public class SearchCreditEntryResponse {

    private int id;
    private CreditEntryEnum paymentType;

    private String billNumber;

    private LocalDate date;

    private String referenceNumber;

    private LocalDate referenceDate;

    private Double receivedAmount;

    private String supplierName;

    private String customerName;


    private String slipNumber;

    private DrawTypeEnum drawType;

    private String remark;

    private int supplierId;
    private int customerId;

    private String supplierCity;
    private String customerCity;


}
