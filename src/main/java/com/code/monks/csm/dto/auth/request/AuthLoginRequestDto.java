package com.code.monks.csm.dto.auth.request;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthLoginRequestDto {
    private String username;
    private String password;
}
