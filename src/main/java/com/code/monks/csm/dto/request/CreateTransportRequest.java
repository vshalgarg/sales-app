package com.code.monks.csm.dto.request;

import com.code.monks.csm.enums.StatusEnum;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateTransportRequest {
    private String name;
    private String gstNo;

    @NotBlank(message = "Contact number is required")
    private String contactNumber;
    private String city;
    private String address;
    private StatusEnum status;
}
