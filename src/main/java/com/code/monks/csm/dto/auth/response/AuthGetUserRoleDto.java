package com.code.monks.csm.dto.auth.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthGetUserRoleDto {
    private Long userId;
    private String username;
    private List<String> roles;
}

