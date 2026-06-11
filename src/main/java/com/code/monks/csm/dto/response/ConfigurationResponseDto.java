package com.code.monks.csm.dto.response;

import com.code.monks.csm.enums.ConfigurationTypeEnum;
import lombok.Builder;

@Builder
public record ConfigurationResponseDto(
        Integer id,
        String key,
        String value,
        ConfigurationTypeEnum type
) {
}
