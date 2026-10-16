package com.code.monks.csm.dto.auth.response;

import com.code.monks.csm.dto.response.Permission;
import lombok.Data;
import java.util.List;
@Data
public class AuthGetPermissionsByRoleTemplateDto {
    private List<Permission> assigned;
    private List<Permission> remaining;
}
