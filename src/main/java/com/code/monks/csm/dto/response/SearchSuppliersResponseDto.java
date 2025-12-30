package com.code.monks.csm.dto.response;

import com.code.monks.csm.dto.request.ContactRequestDto;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class SearchSuppliersResponseDto {
    private int id;
    private String code;
    private String supplierName;
    private String supplierGroup;
    private String supplierGstNo;
    private String commissionScheme;
    private double commissionRate;
    private String address;
    private String city;
    private String pinCode;
    private List<ContactRequestDto> contacts;
    private String supplierMsme;
    private String[] preferredTransport;
    private String remark;
}
