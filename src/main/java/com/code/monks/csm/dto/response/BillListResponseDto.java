package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Builder
public class BillListResponseDto {
    private Integer id;
    private String billNumber;
    private LocalDate date;
    private LocalDate receivedDate;
    private String invoiceNo;
    private String supplierName;
    private String customerName;
    private BigDecimal billAmount;
    private String supplierCity;
    private String customerCity;
}
