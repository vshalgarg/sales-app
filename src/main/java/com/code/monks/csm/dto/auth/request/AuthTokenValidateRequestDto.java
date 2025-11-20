package com.code.monks.csm.dto.auth.request;

import lombok.Data;

@Data
public class AuthTokenValidateRequestDto {
    private String jwtToken;
}
