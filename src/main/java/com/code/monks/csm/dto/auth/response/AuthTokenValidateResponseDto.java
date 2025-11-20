package com.code.monks.csm.dto.auth.response;

import lombok.Data;

import java.util.Set;

@Data
public class AuthTokenValidateResponseDto {
    private Long userId;
    private String username;
    private Set<String> roles;
}
