package com.code.monks.csm.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class SupplierListResponseDto {

    private int id;
    private String code;
    private String supplierName;
    private String supplierGstNo;
    private String address;
    private String city;
    private String mobile;
}
