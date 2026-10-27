
package com.code.monks.csm.dto.auth.response;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthUpdateUserRolesResponseDto {
    private Long userId;
    private String username;
    private List<String> roles;
    private String message;
}
