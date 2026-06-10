package com.code.monks.csm.dto.response;

import lombok.Builder;

@Builder
public record ConfigurationResponseDto(
        Integer id,
        String key,
        String value
) {
}
