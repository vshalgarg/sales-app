package com.code.monks.csm.dto.response;

import com.code.monks.csm.dto.request.AddSupplierRequestDto;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.enums.StatusEnum;
import lombok.Builder;
import lombok.Data;

import java.util.Optional;

@Data
@Builder
public class AddSupplierResponseDto {
    private String message;

    public static SupplierEntity dtoToEntity(AddSupplierRequestDto requestDto){
        SupplierEntity entity = new SupplierEntity();
        entity.setSupplierName(requestDto.getSupplierName());
        entity.setReferenceBy(requestDto.getReferenceBy());
        entity.setEmail(requestDto.getEmail());
        entity.setGroupName(requestDto.getSupplierGroup());
        entity.setGstNo(requestDto.getSupplierGstNo());
        entity.setCommissionScheme(requestDto.getCommissionScheme());
        entity.setCommissionRate(
                Optional.ofNullable(requestDto.getCommissionRate()).orElse(0.0)
        );
        entity.setAddressLine1(requestDto.getAddressLine1());
        entity.setAddressLine2(requestDto.getAddressLine2());
        entity.setState(requestDto.getState());
        entity.setCity(requestDto.getCity());
        entity.setPinCode(requestDto.getPinCode());
        entity.setMsme(requestDto.getSupplierMsme());
       // entity.setPreferredTransport(requestDto.getPreferredTransport());
        entity.setRemark(requestDto.getRemark());
        entity.setStatus(StatusEnum.ACTIVE);
        return entity;
    }
}
