package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Data
@Builder
public class SearchUsersResponseDTO {
    private Long id;
    private String username;
    private Set<String> roles = new HashSet<>();
}

