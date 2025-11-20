package com.code.monks.csm.dto.response;

import com.code.monks.csm.entity.ContactEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.dto.request.AddCustomerRequestDto;
import com.code.monks.csm.entity.CustomerEntity;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class AddCustomerResponseDto {
    private String message;

    public static CustomerEntity dtoToEntity(AddCustomerRequestDto requestDto){
        CustomerEntity entity = new CustomerEntity();
        entity.setCustomerName(requestDto.getCustomerName());
        entity.setGroupName(requestDto.getCustomerGroup());
        entity.setGstNo(requestDto.getCustomerGstNo());
        entity.setMsme(requestDto.getCustomerMsme());
        entity.setReferencedBy(requestDto.getReferencedBy());
        entity.setAddressLine1(requestDto.getAddressLine1());
        entity.setAddressLine2(requestDto.getAddressLine2());
        entity.setCity(requestDto.getCity());
        entity.setPinCode(requestDto.getPinCode());
        entity.setPreferredTransport(requestDto.getPreferredTransport());
        entity.setRemark(requestDto.getRemark());
        entity.setStatus(StatusEnum.ACTIVE);
        return entity;
    }
}
