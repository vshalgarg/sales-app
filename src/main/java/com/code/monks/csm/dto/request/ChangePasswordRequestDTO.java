package com.code.monks.csm.dto.request;

import lombok.Data;

@Data
public class ChangePasswordRequestDTO {
    private Long userId;
    private String newPassword;
}
