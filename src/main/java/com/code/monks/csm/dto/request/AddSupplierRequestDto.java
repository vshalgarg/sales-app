package com.code.monks.csm.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.util.List;

@Data
public class AddSupplierRequestDto {
    @NotBlank(message = "Supplier name is required")
    private String supplierName;

    @NotBlank(message = "Group name is required")
    private String supplierGroup;

    private String supplierGstNo;

    @NotBlank(message = "Msme is required")
    private String supplierMsme;
    
    @NotBlank(message = "Commission scheme is required")
    private String commissionScheme;

    @NotNull(message = "Commission rate is required")
    @DecimalMin(value = "0.0", inclusive = true, message = "Commission rate must be positive")
    private Double commissionRate;

    @NotBlank(message = "Address line 1 is required")
    private String addressLine1;

    @NotBlank(message = "Address line 2 is required")
    private String addressLine2;

    @NotBlank(message = "State is required")
    private String state;

    @NotBlank(message = "City is required")
    private String city;

    @NotNull(message = "PIN code is required")
    private String pinCode;

    @NotNull(message = "Preferred transport is required")
    private List<Integer> preferredTransportIds;

    private String remark;

    @Valid
    @NotNull(message = "Contacts are required")
    private List<ContactRequestDto> contacts;

}
