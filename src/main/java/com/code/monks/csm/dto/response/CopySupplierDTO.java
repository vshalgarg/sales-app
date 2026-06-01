package com.code.monks.csm.dto.response;

public record CopySupplierDTO(
         String supplierName,
         String accountName,
         String accountNumber,
         String ifscCode,
         String branchName,
         String bankName
)
{ }
