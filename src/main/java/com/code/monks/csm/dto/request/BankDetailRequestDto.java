package com.code.monks.csm.dto.request;

import lombok.Data;

@Data
public class BankDetailRequestDto {
    private Integer id;
    private String bankName;
    private String ifscCode;
    private String branchName;
    private String accountName;
    private String accountNumber;
}

