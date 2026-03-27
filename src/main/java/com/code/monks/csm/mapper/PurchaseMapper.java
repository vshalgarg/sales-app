package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.purchase.PurchaseDetailResponse;
import com.code.monks.csm.dto.purchase.PurchaseImageDto;
import com.code.monks.csm.dto.purchase.SupplierPurchaseDetailDto;
import com.code.monks.csm.dto.response.SearchPurchaseEntryResponse;
import com.code.monks.csm.entity.PurchaseEntity;
import com.code.monks.csm.entity.PurchaseImageEntity;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
public class PurchaseMapper {

    public PurchaseDetailResponse toDetail(PurchaseEntity entity, String staffName) {

        if (entity == null) {
            return null;
        }

        List<PurchaseImageDto> images = new ArrayList<>();

        if (entity.getImages() != null) {

            for (PurchaseImageEntity image : entity.getImages()) {

                images.add(
                        PurchaseImageDto.builder()
                                .key(image.getObjectKey())
                                .url(image.getPublicUrl())
                                .build()
                );
            }
        }

        SupplierPurchaseDetailDto supplier = null;

        if (entity.getSupplier() != null) {

            supplier = SupplierPurchaseDetailDto.builder()
                    .supplierId(entity.getSupplier().getId())
                    .supplierName(entity.getSupplier().getSupplierName())
                    .images(images)
                    .build();
        }

        return PurchaseDetailResponse.builder()
                .id(entity.getId())
                .date(entity.getDate())

                .staffId(entity.getStaffId())
                .staffName(staffName)

                .customerId(
                        entity.getCustomer() != null
                                ? entity.getCustomer().getId()
                                : null
                )

                .customerName(
                        entity.getCustomer() != null
                                ? entity.getCustomer().getCustomerName()
                                : null
                )

                .remarks(entity.getRemarks())

                .supplier(supplier)

                .build();
    }

    public SearchPurchaseEntryResponse toSearch(PurchaseEntity entity, String staffName) {

        List<String> supplierNames = new ArrayList<>();

        if (entity.getSupplier() != null) {
            supplierNames.add(entity.getSupplier().getSupplierName());
        }

        return SearchPurchaseEntryResponse.builder()
                .id(entity.getId())
                .date(entity.getDate())
                .staffName(staffName)
                .supplierNames(supplierNames)
                .customerName(
                        entity.getCustomer() != null
                                ? entity.getCustomer().getCustomerName()
                                : null
                )
                .remarks(entity.getRemarks())
                .build();
    }
}