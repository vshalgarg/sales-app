package com.code.monks.csm.dto.purchase;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class PurchaseImageDto {
    private String key;
    private String url;
    private String fileName;
}
