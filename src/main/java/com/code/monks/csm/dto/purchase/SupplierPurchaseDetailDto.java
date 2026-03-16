package com.code.monks.csm.dto.purchase;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class SupplierPurchaseDetailDto {

    private Integer supplierId;
    private String supplierName;

    private List<PurchaseImageDto> images;
}
