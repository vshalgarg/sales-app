package com.code.monks.csm.dto;

import lombok.Data;

import java.util.Set;

@Data
public class User {
    private Long userId;
    private String username;
    private Set<String> roles;
}
