package com.code.monks.csm.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class SupplierSummaryDto {
    private int id;
    private String supplierName;
    private String supplierGroup;
    private String supplierGstNo;
    private String supplierMsme;
    private String city;
}
