package com.code.monks.csm.dto.auth.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;
@Data
@AllArgsConstructor
public class AuthUpdateRoleRequestDto {
    @NotBlank(message = "Role name is required")
    private String roleName;

    private String roleDesc;

    @NotNull(message = "Permissions are required")
    private List<Integer> permissionIds;

    private Integer parentRoleId;

}

