package com.code.monks.csm.dto.response;

import lombok.Data;
import java.util.List;

@Data
public class GetPermissionsByRoleTemplateDto {
    private List<Permission> assigned;
    private List<Permission> remaining;
}
