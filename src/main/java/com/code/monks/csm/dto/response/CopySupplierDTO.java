package com.code.monks.csm.dto.response;

import java.util.List;

public record CopySupplierDTO(
         String supplierName,
         List<BankDetailResponseDto> bankDetails
)
{ }
