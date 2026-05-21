package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.response.BillDetailResponseDto;
import com.code.monks.csm.dto.response.BillItemDto;
import com.code.monks.csm.dto.response.BillListResponseDto;
import com.code.monks.csm.entity.BillEntryEntity;
import com.code.monks.csm.utils.MoneyUtil;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;

@Component
public class BillMapper {

    public BillListResponseDto toListDto(BillEntryEntity entity) {

        return BillListResponseDto.builder()
                .id(entity.getId())
                .billNumber(entity.getBillNumber())
                .date(entity.getDate())
                .receivedDate(entity.getReceivedDate())
                .invoiceNo(entity.getInvoiceNo())
                .supplierName(
                        entity.getSupplier() != null
                                ? entity.getSupplier().getSupplierName()
                                : null
                )
                .customerName(
                        entity.getCustomer() != null
                                ? entity.getCustomer().getCustomerName()
                                : null
                )
                .billAmount(MoneyUtil.toRupee(entity.getBillAmount()))
                .supplierCity(entity.getSupplier().getCity())
                .customerCity(entity.getCustomer().getCity())
                .build();
    }

    public BillDetailResponseDto toDetailDto(BillEntryEntity entity) {

        List<BillItemDto> items = entity.getBillDetails()
                .stream()
                .map(detail -> BillItemDto.builder()
                        .pieces(detail.getPieces())
                        .grossAmount(MoneyUtil.toRupee(detail.getGrossAmount()))
                        .discountAmount(MoneyUtil.toRupee(detail.getDiscountAmount()))
                        .addOnAmount(MoneyUtil.toRupee(detail.getAddOnAmount()))
                        .ecrAmount(MoneyUtil.toRupee(detail.getEcrAmount()))
                        .gstAmount(MoneyUtil.toRupee(detail.getGstAmount()))
                        .discountPercent(MoneyUtil.basisPointToPercent(detail.getDiscountPercent()))
                        .gstPercent(MoneyUtil.basisPointToPercent(detail.getGstPercent()))
                        .build())
                .toList();

        List<String> publicUrls = entity.getImages()
                .stream()
                .map(img -> img.getPublicUrl())
                .toList();

        List<String> objectKeys = entity.getImages()
                .stream()
                .map(img -> img.getObjectKey())
                .toList();

        List<String> fileNames = entity.getImages()
                .stream()
                .map(img -> img.getOriginalFileName())
                .toList();

        return BillDetailResponseDto.builder()
                .id(entity.getId())
                .billNumber(entity.getBillNumber())
                .date(entity.getDate())
                .receivedDate(entity.getReceivedDate())
                .invoiceNo(entity.getInvoiceNo())

                .billAmount(MoneyUtil.toRupee(entity.getBillAmount()))
                .taxableValue(MoneyUtil.toRupee(entity.getTaxableValue()))

                .transport(entity.getTransportEntity() != null
                        ? entity.getTransportEntity().getName()
                        : null)

                .lrNumber(entity.getLrNumber())
                .remarks(entity.getRemarks())

                // Supplier
                .supplierId(entity.getSupplier().getId())
                .supplierName(entity.getSupplier().getSupplierName())
                .supplierGroup(entity.getSupplier().getGroupName())
                .supplierGstNo(entity.getSupplier().getGstNo())
                .supplierMsme(entity.getSupplier().getMsme())

                // Customer
                .customerId(entity.getCustomer().getId())
                .customerName(entity.getCustomer().getCustomerName())
                .customerGroup(entity.getCustomer().getGroupName())
                .customerGstNo(entity.getCustomer().getGstNo())
                .customerMsme(entity.getCustomer().getMsme())

                .items(items)
                .publicUrls(publicUrls)
                .objectKeys(objectKeys)
                .originalFileNames(fileNames)

                .build();
    }
}
