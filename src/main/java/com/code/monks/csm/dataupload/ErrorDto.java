package com.code.monks.csm.dataupload;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@AllArgsConstructor
@Data
@Builder
public class ErrorDto {
    private String fileName;
    private String errorMessage;
    private String supplierName;
    private String customerName;


}
