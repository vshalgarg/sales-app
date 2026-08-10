package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class BankDetailRequestDto {

    @NotBlank(message = "Bank name is required")
    private String bankName;

    @NotBlank(message = "IFSC code is required")
    private String ifscCode;

    private String branchName;

    private String accountName;

    @NotBlank(message = "Account number is required")
    private String accountNumber;
}

