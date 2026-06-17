package com.code.monks.csm.dto.ledger;

import lombok.Builder;

@Builder
public record LedgerPartyDto(
        Integer id,
        String name,
        String email,
        String phone,
        String gstNo,
        String address
) {
}
