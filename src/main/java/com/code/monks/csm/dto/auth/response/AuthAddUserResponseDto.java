package com.code.monks.csm.dto.auth.response;

import com.code.monks.csm.enums.StatusEnum;
import lombok.Data;

@Data
public class AuthAddUserResponseDto {
    private StatusEnum status;
}
