package com.code.monks.csm.dto.request;

import com.code.monks.csm.enums.MsmeEnum;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;
import java.util.Set;

@Data
public class UpdateSupplierRequestDto {

    @NotBlank(message = "Supplier name is required")
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

    @Size(max = 10, message = "Pin code cannot exceed 10 characters")
    private String pinCode;

    private MsmeEnum msme;

    private List<BankDetailRequestDto> bankDetails;

    private Set<Integer> preferredTransportIds;

    private String remark;

    private List<ContactRequestDto> contacts;
}
