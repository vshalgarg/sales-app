package com.code.monks.csm.dto.response;

import lombok.Data;

@Data
public class CreateTransportResponseDto {

    private Integer id;
    private String name;
    private Boolean isActive;
    private boolean success;
    private String message;
}
