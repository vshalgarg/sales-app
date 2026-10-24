package com.code.monks.csm.dto.auth.request;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuthUpdateUserRolesRequestDto {
    private List<String> roleNames;
}
