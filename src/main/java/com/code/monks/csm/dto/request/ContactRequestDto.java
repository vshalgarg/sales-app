package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ContactRequestDto {
    @NotBlank(message = "Contact person name is required")
    private String contactPerson;

    @NotBlank(message = "Mobile number is required")
    private String mobileNumber;

    private String type;
}
