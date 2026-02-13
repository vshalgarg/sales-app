package com.code.monks.csm.dto.response;

import com.code.monks.csm.dto.request.ContactRequestDto;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class GetSuppliersDto {
    private int id;
    private String code;
    private String supplierName;
    private String supplierGroup;
    private String supplierGstNo;
    private String supplierMsme;
    private String email;
    private String referenceBy;
    private String commissionScheme;
    private Double commissionRate;
    private String address;
    private String state;
    private String city;
    private String pinCode;
    private List<ContactRequestDto> contacts;
    private List<TransportDto> preferredTransports;
    //private String[] preferredTransport;
    private String remark;
}
