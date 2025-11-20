package com.code.monks.csm.dto.response;

import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.entity.PurchaseEntity;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AddPurchaseEntryResponseDto {
    private String message;

    public static PurchaseEntity dtoToEntity(AddPurchaseEntryRequestDto requestDto){
        PurchaseEntity entity = new PurchaseEntity();
        entity.setDate(requestDto.getDate());
        entity.setStaffId(requestDto.getStaffId());
        entity.setSupplierId(requestDto.getSupplierId());
        entity.setCustomerId(requestDto.getCustomerId());
        entity.setPurchaseAmount(Math.round(requestDto.getPurchaseAmount())*100);
        return entity;
    }
}
