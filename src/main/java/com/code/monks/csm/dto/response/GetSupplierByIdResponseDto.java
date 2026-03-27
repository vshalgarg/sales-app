package com.code.monks.csm.dto.response;

import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.dto.request.ContactRequestDto;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class GetSupplierByIdResponseDto {

    private Integer id;
    private String code;
    private String supplierName;
    private String email;
    private String groupName;
    private String gstNo;
    private String commissionScheme;
    private Double commissionRate;
    private String referenceBy;
    private String addressLine1;
    private String addressLine2;
    private String state;
    private String city;
    private String pinCode;
    private String msme;
    private String bankName;
    private String ifscCode;
    private String branchName;
    private String accountName;
    private String accountNumber;
    private String remark;
    private StatusEnum status;

    private List<ContactRequestDto> contacts;
    private List<TransportDto> preferredTransports;
}
