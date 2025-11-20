package com.code.monks.csm.dto.auth.response;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class AuthGetUsersDto {
    private List<Map<String,Object>> users;
}
