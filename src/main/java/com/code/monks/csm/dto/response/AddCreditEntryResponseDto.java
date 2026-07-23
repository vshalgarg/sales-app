package com.code.monks.csm.dto.response;

import com.code.monks.csm.dto.request.AddCreditEntryRequestDto;
import com.code.monks.csm.entity.CreditEntryEntity;
import com.code.monks.csm.utils.MoneyUtil;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;

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

        entity.setReceivedAmount(MoneyUtil.toPaisaBigInteger(
                dto.getReceivedAmount() == null ? BigDecimal.ZERO : BigDecimal.valueOf(dto.getReceivedAmount())));

        entity.setDrawType(dto.getDrawType());
        entity.setRemark(dto.getRemark());
        entity.setSupplierId(dto.getSupplierId());
        entity.setCustomerId(dto.getCustomerId());
        entity.setSlipNumber(dto.getSlipNumber());
        return entity;
    }
}
