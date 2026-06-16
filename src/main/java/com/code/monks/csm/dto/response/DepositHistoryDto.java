package com.code.monks.csm.dto.response;

import lombok.Builder;

import java.time.LocalDate;

@Builder
public record DepositHistoryDto(

        LocalDate date,
        Long amount
) {
}
