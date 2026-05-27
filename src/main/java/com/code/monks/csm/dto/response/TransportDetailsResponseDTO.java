package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class TransportDetailsResponseDTO {

    private Integer id;
    private String name;
    private String email;
    private String gstNo;
    private String state;
    private String city;
    private String pinCode;
    private String addressLine1;
    private String addressLine2;
    private String status;
    private List<TransportContactResponseDto> contacts;
}
