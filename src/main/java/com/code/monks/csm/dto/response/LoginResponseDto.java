package com.code.monks.csm.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.util.Set;

@Data
@Builder
@AllArgsConstructor
public class LoginResponseDto {
    private Long userId;
    private String username;
    private Set<String> roles;
    private String token;
}
