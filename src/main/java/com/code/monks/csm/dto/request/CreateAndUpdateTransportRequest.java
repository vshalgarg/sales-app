package com.code.monks.csm.dto.request;

import com.code.monks.csm.enums.StatusEnum;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.List;

@Data
public class CreateAndUpdateTransportRequest {

    @NotBlank(message = "Transport name is required")
    private String name;

    @Email(message = "Invalid email format")
    private String email;

    private String gstNo;

    @Valid
    private List<TransportContactRequestDto> contacts;

    private String state;
    private String city;
    private String pincode;

    @NotBlank(message = "Address Line 1 is required")
    private String addressLine1;

    private String addressLine2;

    private StatusEnum status;
}
