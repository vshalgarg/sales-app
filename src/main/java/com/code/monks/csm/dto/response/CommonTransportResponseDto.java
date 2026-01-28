package com.code.monks.csm.dto.response;

import lombok.Data;

@Data
public class CommonTransportResponseDto {

    private boolean success;
    private String message;
    private Integer id;
}
