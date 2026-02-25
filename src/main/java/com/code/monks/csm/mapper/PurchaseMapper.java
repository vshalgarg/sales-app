package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.response.PurchaseDetailResponse;
import com.code.monks.csm.dto.response.SearchPurchaseEntryResponse;
import com.code.monks.csm.entity.PurchaseEntity;
import com.code.monks.csm.entity.PurchaseImageEntity;
import com.code.monks.csm.entity.StaffEntity;
import com.code.monks.csm.repository.StaffRepo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Component
@RequiredArgsConstructor
public class PurchaseMapper {

    private final StaffRepo staffRepo;

    public PurchaseDetailResponse toDetail(PurchaseEntity entity) {

        StaffEntity staff =
                entity.getStaffId() != null
                        ? staffRepo.findById(entity.getStaffId()).orElse(null)
                        : null;

        List<String> imageKeys = new ArrayList<>();
        List<String> publicUrls = new ArrayList<>();

        if (entity.getImages() != null) {
            for (PurchaseImageEntity image : entity.getImages()) {
                imageKeys.add(image.getObjectKey());
                publicUrls.add(image.getPublicUrl());
            }
        }

        return PurchaseDetailResponse.builder()
                .id(entity.getId())
                .date(entity.getDate())

                .staffId(entity.getStaffId())
                .staffName(staff != null ? staff.getStaffName() : null)

                .supplierIds(
                        entity.getSuppliers()
                                .stream()
                                .map(s -> s.getId())
                                .toList()
                )
                .supplierNames(
                        entity.getSuppliers()
                                .stream()
                                .map(s -> s.getSupplierName())
                                .toList()
                )

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

                .purchaseAmount(
                        entity.getPurchaseAmount() != null
                                ? entity.getPurchaseAmount() / 100.0
                                : 0.0
                )

                .imageKeys(imageKeys)
                .publicUrls(publicUrls)

                .build();
    }


    public SearchPurchaseEntryResponse toSearch(PurchaseEntity entity) {

        PurchaseDetailResponse detail = toDetail(entity);

        return SearchPurchaseEntryResponse.builder()
                .id(detail.getId())
                .date(detail.getDate())
                .staffId(detail.getStaffId())
                .staffName(detail.getStaffName())
                .publicUrls(detail.getPublicUrls())
                .supplierIds(detail.getSupplierIds())
                .supplierNames(detail.getSupplierNames())
                .customerId(detail.getCustomerId())
                .customerName(detail.getCustomerName())
                .purchaseAmount(detail.getPurchaseAmount())
                .build();
    }
}