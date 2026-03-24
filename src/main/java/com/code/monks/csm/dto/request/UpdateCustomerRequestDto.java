package com.code.monks.csm.dto.request;

import com.code.monks.csm.enums.StatusEnum;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

import java.util.List;
import java.util.Set;

@Data
public class UpdateCustomerRequestDto {

    @NotBlank(message = "Customer name is required")
    private String customerName;

    private String email;

    private String groupName;

    private String gstNo;

    private String referencedBy;

    private String addressLine1;

    private String addressLine2;

    private String state;

    private String city;

    @Size(max = 10, message = "Pin code cannot exceed 10 characters")
    private String pinCode;

    private String msme;

    private String bankName;
    private String ifsc;
    private String branch;
    private String accountName;
    private String accountNumber;

    private Set<Integer> preferredTransportIds;

    private String remark;

    private List<ContactRequestDto> contacts;
}
