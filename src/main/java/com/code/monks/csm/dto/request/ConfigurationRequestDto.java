package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Builder;

@Builder
public record ConfigurationRequestDto(

        @NotBlank(message = "Configuration key is required")
        String key,

        @NotBlank(message = "Configuration value is required")
        String value,

        String description
) {
}