package com.code.monks.csm.dto.response;

import com.code.monks.csm.dto.request.ContactRequestDto;
import com.code.monks.csm.enums.StatusEnum;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class GetCustomerByIdResponseDto {

    private Integer id;
    private String code;
    private String customerName;
    private String email;
    private String groupName;
    private String gstNo;
    private String referencedBy;
    private String addressLine1;
    private String addressLine2;
    private String state;
    private String city;
    private String pinCode;
    private String msme;
    private String remark;
    private StatusEnum status;
    private String bankName;
    private String ifsc;
    private String branch;
    private String accountName;
    private String accountNumber;
    private List<ContactRequestDto> contacts;
    private List<TransportDto> preferredTransports;
}
