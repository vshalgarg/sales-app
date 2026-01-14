package com.code.monks.csm.dto.auth.request;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthChangePasswordReqDTO {
    private Long userId;
    private String newPassword;
}
