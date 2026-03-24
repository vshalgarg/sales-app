package com.code.monks.csm.dto.request;

import lombok.Data;

import java.time.LocalDate;

@Data
public class CreditUpdateRequest {

    private LocalDate date;
    private Integer supplierId;
    private Integer customerId;

    private String paymentType;
    private String referenceNumber;
    private LocalDate referenceDate;

    private String slipNumber;
    private String drawType;

    private Double receivedAmount;
    private String remark;
}
