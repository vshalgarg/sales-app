package com.code.monks.csm.dto.request;

import com.code.monks.csm.enums.StatusEnum;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.List;
import java.util.Set;

@Data
public class UpdateCustomerRequestDto {

    @NotBlank(message = "Customer name is required")
    private String customerName;

    @Email(message = "Invalid email format")
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

    private Set<Integer> preferredTransportIds;

    private String remark;

    private StatusEnum status;

    private List<ContactRequestDto> contacts;
}
