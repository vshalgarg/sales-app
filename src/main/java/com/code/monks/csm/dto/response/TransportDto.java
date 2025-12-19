package com.code.monks.csm.dto.response;

import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TransportDto {
    private Integer id;
    private String name;
    private Boolean isActive;
}
