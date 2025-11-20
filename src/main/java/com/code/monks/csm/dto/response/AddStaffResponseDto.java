package com.code.monks.csm.dto.response;

import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.dto.request.AddStaffRequestDto;
import com.code.monks.csm.entity.StaffEntity;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class AddStaffResponseDto {
    private String message;

    public static StaffEntity dtoToEntity(AddStaffRequestDto requestDto){
        StaffEntity entity = new StaffEntity();
        entity.setStaffName(requestDto.getStaffName());
        entity.setPhone(requestDto.getPhone());
        entity.setJoiningDate(requestDto.getJoiningDate());
        entity.setStatus(StatusEnum.ACTIVE);
        return entity;
    }
}
