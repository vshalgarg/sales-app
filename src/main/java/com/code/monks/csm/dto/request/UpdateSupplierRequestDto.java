package com.code.monks.csm.dto.request;

import com.code.monks.csm.enums.StatusEnum;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;
import java.util.Set;

@Data
public class UpdateSupplierRequestDto {

    @NotBlank(message = "Supplier name is required")
    private String supplierName;

    @Email(message = "Invalid email format")
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

    private String msme;

    private Set<Integer> preferredTransportIds;

    private String remark;

    private StatusEnum status;

    private List<ContactRequestDto> contacts;
}
