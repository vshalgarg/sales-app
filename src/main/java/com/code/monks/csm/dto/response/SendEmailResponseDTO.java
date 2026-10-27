package com.code.monks.csm.dto.response;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SendEmailResponseDTO {

    private boolean success;
    private String message;
    private String providerMessageId;
}
