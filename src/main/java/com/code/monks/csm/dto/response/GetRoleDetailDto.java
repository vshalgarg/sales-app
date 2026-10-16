package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class GetRoleDetailDto {
    private String roleName;
    private String roleDesc;
    private Integer parentRoleId;
    private String parentRoleName;
    private List<Permission> permissions;
}
