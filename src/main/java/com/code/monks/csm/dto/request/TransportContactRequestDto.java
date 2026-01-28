package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class TransportContactRequestDto {

    private String contactPerson;

    @NotBlank(message = "Contact number is required")
    @Pattern(
            regexp = "\\d{10}",
            message = "Contact number must be exactly 10 digits"
    )
    private String contactNumber;
}
