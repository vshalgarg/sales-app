package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class DeleteUserRequestDto {
    @NotNull(message = "User Id is required.")
    private Long userId;
    
    @NotBlank(message = "Username is required.")
    private String username;
}
