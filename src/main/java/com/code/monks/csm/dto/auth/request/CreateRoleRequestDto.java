package com.code.monks.csm.dto.auth.request;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.Set;

@Data
public class CreateRoleRequestDto {

    @NotBlank(message = "Role Name is required")
    private String roleName;

    private String roleDesc;

    @NotNull(message = "Permissions Id are required")
    private Set<Integer> permissionIds;

    private Integer parentRoleId;

}
