package com.code.monks.csm.dto.response;

import lombok.Data;
import java.util.List;

@Data
public class UpdateRoleRequestDto {
    private String roleName;

    private String roleDesc;

    private List<Integer> permissionIds;

    private Integer parentRoleId;
}

