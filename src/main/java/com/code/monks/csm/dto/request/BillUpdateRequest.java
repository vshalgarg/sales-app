package com.code.monks.csm.dto.request;

import com.code.monks.csm.dto.response.BillItemDto;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class BillUpdateRequest {
    private String date;
    private String receivedDate;
    private String order;

    private Integer supplierId;
    private Integer customerId;

    private String transport;
    private String lrNumber;
    private String remarks;
    private BigDecimal taxableValue;
    private BigDecimal billAmount;
    private List<BillItemDto> billItems;
}
