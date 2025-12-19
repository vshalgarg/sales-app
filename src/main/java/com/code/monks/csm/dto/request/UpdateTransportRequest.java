package com.code.monks.csm.dto.request;

import lombok.Data;

@Data
public class UpdateTransportRequest {

    private Integer id;
    private String name;
    private Boolean isActive;
}
