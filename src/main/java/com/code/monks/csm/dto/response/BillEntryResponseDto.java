package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class BillEntryResponseDto {
    private String message;

//    public static BillEntryEntity dtoToEntity(BillEntryRequestDto dto, String billNumber) {
//        if (dto == null) {
//            return null;
//        }
//
//        BillEntryEntity entity = new BillEntryEntity();
//        entity.setBillNumber(billNumber);
//        entity.setDate(dto.getDate());
//        entity.setReceivedDate(dto.getReceivedDate());
//        entity.setOrders(dto.getOrder());
//        entity.setPieces(dto.getPieces());
//
//        entity.setGrossAmount(Math.round(dto.getGrossAmount() * 100));
//        entity.setDiscountPercent(Math.round(dto.getDiscountPercent() * 100));
//        entity.setDiscountAmount(Math.round(dto.getDiscountAmount() * 100));
//        entity.setGstPercent(Math.round(dto.getGstPercent() * 100));
//        entity.setGstAmount(Math.round(dto.getGstAmount() * 100));
//        entity.setBillAmount(Math.round(dto.getBillAmount() * 100));
//        entity.setAddOnAmount(Math.round(dto.getAddOnAmount() * 100));
//        entity.setEcrAmount(Math.round(dto.getEcrAmount()));
//        entity.setTaxableValue(Math.round(dto.getTaxableValue() * 100));
//
//        entity.setTransport(dto.getTransport());
//        entity.setLrNumber(dto.getLrNumber());
//        entity.setRemarks(dto.getRemarks());
//        entity.setSupplierId(dto.getSupplierId());
//        entity.setCustomerId(dto.getCustomerId());
//
//        return entity;
//    }


}
