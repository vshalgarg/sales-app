package com.code.monks.csm.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class AddCustomerRequestDto {
    @NotBlank(message = "Customer name is required")
    private String customerName;

    @NotBlank(message = "Group name is required")
    private String customerGroup;

    private String customerGstNo;

    @NotBlank(message = "Customer msme is required")
    private String customerMsme;

    private String referencedBy;

    @NotBlank(message = "Address line 1 is required")
    private String addressLine1;

    @NotBlank(message = "Address line 2 is required")
    private String addressLine2;

    @NotBlank(message = "City is required")
    private String city;

    @NotBlank(message = "PIN code is required")
    private String pinCode;

    private List<Integer> preferredTransportIds;

    private String remark;

    @Valid
    @NotNull(message = "Contacts are required")
    private List<ContactRequestDto> contacts;

}
