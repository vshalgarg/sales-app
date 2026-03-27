package com.code.monks.csm.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class CustomerSummaryResponseDto {
    private int id;
    private String customerName;
    private String customerGroup;
    private String customerGstNo;
    private String customerMsme;
    private String city;

}
