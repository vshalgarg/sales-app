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
        entity.setChequeNumber(dto.getChequeNumber());
        entity.setChequeDate(dto.getChequeDate());
        entity.setReceivedAmount(Math.round(dto.getReceivedAmount() * 100));
        entity.setSupplierCurrentBalance(Math.round(dto.getSupplierCurrentBalance() * 100));
        entity.setCustomerCurrentBalance(Math.round(dto.getCustomerCurrentBalance() * 100));
        entity.setDrawType(dto.getDrawType());
        entity.setRemark(dto.getRemark());
        entity.setSupplierId(dto.getSupplierId());
        entity.setCustomerId(dto.getCustomerId());
        return entity;
    }
}
