package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class GetAllPermissionsDto {
    private int id;
    private String name;
    private String desc;
}
