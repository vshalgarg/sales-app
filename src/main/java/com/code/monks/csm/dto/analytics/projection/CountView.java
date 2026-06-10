package com.code.monks.csm.dto.analytics.projection;

public record CountView(
        Integer year,
        Integer month,
        Long count
) {
}
