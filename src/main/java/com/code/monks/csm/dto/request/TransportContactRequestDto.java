package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TransportContactRequestDto {

    private String contactPerson;

    @NotBlank(message = "Contact number is required")
    private String contactNumber;
}
