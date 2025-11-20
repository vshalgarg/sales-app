package com.code.monks.csm.dto.auth.response;

import lombok.Data;

@Data
public class AuthEncryptedUserDetailDTO {
    private String encryptedPayload;
}
