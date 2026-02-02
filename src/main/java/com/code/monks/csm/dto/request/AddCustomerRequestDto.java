package com.code.monks.csm.dto.request;

import com.code.monks.csm.enums.converter.EmptyStringToNullConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class AddCustomerRequestDto {
    @NotBlank(message = "Customer name is required")
    private String customerName;

    @Email(message = "Invalid email format")
    private String email;

    private String customerGroup;

    @Convert(converter = EmptyStringToNullConverter.class)
    private String customerGstNo;

    private String customerMsme;

    @Convert(converter = EmptyStringToNullConverter.class)
    private String referencedBy;

    private String addressLine1;

    @Convert(converter = EmptyStringToNullConverter.class)
    private String addressLine2;

    private String state;
    private String city;
    private String pinCode;

    private List<Integer> preferredTransportIds;

    private String remark;

    private List<ContactRequestDto> contacts;

}
