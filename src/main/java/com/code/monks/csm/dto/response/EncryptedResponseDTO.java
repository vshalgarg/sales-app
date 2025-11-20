package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class EncryptedResponseDTO {
    private String encryptedPayload;
}
