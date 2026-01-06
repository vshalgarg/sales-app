package com.code.monks.csm.dto.response;

import com.code.monks.csm.dto.request.AddCreditEntryRequestDto;
import com.code.monks.csm.entity.CreditEntryEntity;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AddCreditEntryResponseDto {
    private String message;

    public static CreditEntryEntity dtoToEntity(AddCreditEntryRequestDto dto) {
        CreditEntryEntity entity = new CreditEntryEntity();
        entity.setPaymentType(dto.getPaymentType());
        entity.setBillNumber(dto.getBillNumber());
        entity.setDate(dto.getDate());
        entity.setReferenceNumber(dto.getReferenceNumber());
        entity.setReferenceDate(dto.getReferenceDate());
        entity.setReceivedAmount(Math.round(dto.getReceivedAmount() * 100));
        entity.setDrawType(dto.getDrawType());
        entity.setRemark(dto.getRemark());
        entity.setSupplierId(dto.getSupplierId());
        entity.setCustomerId(dto.getCustomerId());
        entity.setSlipNumber(dto.getSlipNumber());
        return entity;
    }
}
