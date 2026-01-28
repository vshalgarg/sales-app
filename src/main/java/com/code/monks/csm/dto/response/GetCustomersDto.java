package com.code.monks.csm.dto.response;

import com.code.monks.csm.dto.request.ContactRequestDto;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class GetCustomersDto {
    private int id;
    private String code;
    private String customerName;
    private String email;
    private String customerGroup;
    private String customerGstNo;
    private String customerMsme;
    private String referencedBy;
    private String address;
    private String city;
    private String pinCode;
    private List<ContactRequestDto> contacts;
    private List<TransportDto> preferredTransports;
    private String remark;
}
