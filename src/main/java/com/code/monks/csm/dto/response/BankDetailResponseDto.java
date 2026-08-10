package com.code.monks.csm.dto.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class BankDetailResponseDto {

    private String bankName;

    private String ifscCode;

    private String branchName;

    private String accountName;

    private String accountNumber;
}