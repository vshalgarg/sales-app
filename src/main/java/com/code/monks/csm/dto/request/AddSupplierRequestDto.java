package com.code.monks.csm.dto.request;

import com.code.monks.csm.enums.converter.EmptyStringToNullConverter;
import jakarta.persistence.Convert;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.Data;

import java.util.List;

@Data
public class AddSupplierRequestDto {
    @NotBlank(message = "Supplier name is required")
    private String supplierName;


    private String supplierGroup;

    @Convert(converter = EmptyStringToNullConverter.class)
    private String supplierGstNo;


    private String supplierMsme;
    

    private String commissionScheme;


    @DecimalMin(value = "0.0", inclusive = true, message = "Commission rate must be positive")
    private Double commissionRate;

    @NotBlank(message = "Address line 1 is required")
    private String addressLine1;

    @Convert(converter = EmptyStringToNullConverter.class)
    private String addressLine2;

    @NotBlank(message = "State is required")
    private String state;

    @NotBlank(message = "City is required")
    private String city;

    @NotBlank(message = "PIN code is required")
    private String pinCode;

    @NotNull(message = "Preferred transport is required")
    private List<Integer> preferredTransportIds;

    @Convert(converter = EmptyStringToNullConverter.class)
    private String remark;

    @Valid
    @NotNull(message = "Contacts are required")
    private List<ContactRequestDto> contacts;

}
