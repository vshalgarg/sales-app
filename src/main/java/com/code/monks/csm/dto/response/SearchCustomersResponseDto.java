package com.code.monks.csm.dto.response;

import com.code.monks.csm.dto.request.ContactRequestDto;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class SearchCustomersResponseDto {
    private int id;
    private String code;
    private String customerName;
    private String customerGroup;
    private String customerGstNo;
    private String referencedBy;
    private String address;
    private String state;
    private String city;
    private String pinCode;
    private String customerMsme;
    private List<ContactRequestDto> contacts;
    private List<TransportDto> preferredTransports;
    private String remark;
}
