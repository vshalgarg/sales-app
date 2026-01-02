package com.code.monks.csm.dto.response;

import lombok.Data;

@Data
public class UpdateTransportResponseDto {

    private Integer id;
    private String name;
    private boolean success;
    private String message;
}
