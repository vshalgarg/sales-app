package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class BankDetailRequestDto {
    private String bankName;
    private String ifscCode;
    private String branchName;
    private String accountName;
    private String accountNumber;
}

