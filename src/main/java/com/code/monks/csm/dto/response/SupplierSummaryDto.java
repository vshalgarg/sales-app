package com.code.monks.csm.dto.response;

import com.code.monks.csm.enums.MsmeEnum;
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
    private MsmeEnum supplierMsme;
    private String city;
}
