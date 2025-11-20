package com.code.monks.csm.dto.auth.response;

import lombok.Data;

import java.util.Map;
import java.util.Set;

@Data
public class AuthLoginResponseDto {
    private Long userId;
    private String username;
    private Set<String> roles;
    private String token;
    private Map<String,String> userProfile;
}
