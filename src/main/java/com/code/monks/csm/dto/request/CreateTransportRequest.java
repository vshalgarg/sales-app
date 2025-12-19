package com.code.monks.csm.dto.request;

import lombok.Data;

@Data
public class CreateTransportRequest {
    private String name;
    private Boolean isActive;
}
