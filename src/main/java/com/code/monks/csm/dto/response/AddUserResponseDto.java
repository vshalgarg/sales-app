package com.code.monks.csm.dto.response;

import com.code.monks.csm.enums.StatusEnum;
import lombok.Builder;
import lombok.Data;

@Builder
@Data
public class AddUserResponseDto {
    private StatusEnum status;
}
