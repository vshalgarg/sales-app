package com.code.monks.csm.dto.auth.response;

import com.code.monks.csm.dto.response.Permission;
import lombok.Data;
import java.util.List;

@Data
public class AuthGetRoleDetailDto {
    private String roleName;
    private String roleDesc;
    private Integer parentRoleId;
    private String parentRoleName;
    private List<Permission> permissions;
}
