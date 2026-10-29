package com.code.monks.csm.dto.auth.response;
import lombok.Data;

@Data
public class AuthGetAllPermissionsDto {
    private int id;
    private String name;
    private String desc;
}