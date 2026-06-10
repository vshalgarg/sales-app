package com.code.monks.csm.dto.analytics;

import lombok.Builder;

import java.util.List;

@Builder
public record DatasetDto(
        String label,
        List<?> data,
        String unit
) {
}
