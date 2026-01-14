package com.code.monks.csm.dto.auth.response;

import lombok.Data;

@Data
public class AuthDeleteUserResponseDto {
    private Long userId;
    private String status;
    private String message;
}
