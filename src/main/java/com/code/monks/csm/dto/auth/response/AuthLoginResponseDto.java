package com.code.monks.csm.dto.auth.response;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.Map;
import java.util.Set;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class AuthLoginResponseDto {
    private Long userId;
    private String username;
    private Set<String> roles;
    private String token;
    private Map<String,String> userProfile;
}
