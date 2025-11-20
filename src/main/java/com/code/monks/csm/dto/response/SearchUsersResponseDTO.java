package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class SearchUsersResponseDTO {
    private Long id;
    private String username;
}

