
package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdateUserRoleRequestDto {
    @NotEmpty(message = "Role names are required")
    private List<@NotBlank(message = "Role name cannot be blank") String> roleNames;
}
