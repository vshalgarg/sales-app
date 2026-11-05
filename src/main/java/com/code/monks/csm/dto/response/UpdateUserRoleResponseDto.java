package com.code.monks.csm.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateUserRoleResponseDto {
    private Long userId;
    private String username;
    private List<String> roles;
    private String message;
}
