package com.code.monks.csm.dto.auth.request;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthAddUserRequestDto {
    private String username;
    private String password;
    private String[] roles;
}
