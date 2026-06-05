package com.code.monks.csm.dto.response;

import java.util.List;

public record CopySupplierDetailsResponseDTO(
        List<CopySupplierDTO> suppliers
) {
}
