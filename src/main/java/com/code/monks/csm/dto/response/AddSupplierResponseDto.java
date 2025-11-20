package com.code.monks.csm.dto.response;

import com.code.monks.csm.entity.ContactEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.dto.request.AddSupplierRequestDto;
import com.code.monks.csm.entity.SupplierEntity;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class AddSupplierResponseDto {
    private String message;

    public static SupplierEntity dtoToEntity(AddSupplierRequestDto requestDto){
        SupplierEntity entity = new SupplierEntity();
        entity.setSupplierName(requestDto.getSupplierName());
        entity.setGroupName(requestDto.getSupplierGroup());
        entity.setGstNo(requestDto.getSupplierGstNo());
        entity.setCommissionScheme(requestDto.getCommissionScheme());
        entity.setCommissionRate(requestDto.getCommissionRate());
        entity.setAddressLine1(requestDto.getAddressLine1());
        entity.setAddressLine2(requestDto.getAddressLine2());
        entity.setCity(requestDto.getCity());
        entity.setPinCode(requestDto.getPinCode());
        entity.setMsme(requestDto.getSupplierMsme());
        entity.setPreferredTransport(requestDto.getPreferredTransport());
        entity.setRemark(requestDto.getRemark());
        entity.setStatus(StatusEnum.ACTIVE);
        return entity;
    }
}
