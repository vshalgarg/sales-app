package com.code.monks.csm.dto.response;

import com.code.monks.csm.dto.request.ContactRequestDto;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class CustomerListDto {

    private Integer id;
    private String code;
    private String customerName;
    private String customerGstNo;
    private String address;
    private String city;
    private List<ContactRequestDto> contacts;
}
