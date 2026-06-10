package com.code.monks.csm.dto.analytics;

public record EntryCountDto(
        String month,
        Long billEntryCount,
        Long creditEntryCount
) {
}
