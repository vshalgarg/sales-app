package com.code.monks.csm.dto.response;

import com.code.monks.csm.enums.MsmeEnum;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
@Builder
public class BillDetailResponseDto {
    private Integer id;
    private String billNumber;
    private LocalDate date;
    private LocalDate receivedDate;
    private String invoiceNo;
    private String supplierName;
    private String customerName;
    private BigDecimal billAmount;
    private BigDecimal taxableValue;

    private Integer supplierId;
    private String supplierGroup;
    private String supplierGstNo;
    private MsmeEnum supplierMsme;
    private Integer customerId;
    private String customerGroup;
    private String customerGstNo;
    private MsmeEnum customerMsme;

    private String transport;
    private String lrNumber;
    private String remarks;

    private List<BillItemDto> items;

    public List<String> objectKeys;
    private List<String> publicUrls;
    private List<String> originalFileNames;
}
