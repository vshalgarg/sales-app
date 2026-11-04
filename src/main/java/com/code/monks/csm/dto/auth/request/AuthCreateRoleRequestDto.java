package com.code.monks.csm.dto.auth.request;
import lombok.AllArgsConstructor;
import lombok.Data;
import java.util.Set;

@Data
@AllArgsConstructor
public class AuthCreateRoleRequestDto {
    private String roleName;
    private String roleDesc;
    private Set<Integer> permissionIds;
    private Integer parentRoleId;
}
