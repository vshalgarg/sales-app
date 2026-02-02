package com.code.monks.csm.dto.request;

import lombok.Data;

@Data
public class TransportContactRequestDto {

    private String contactPerson;
    private String contactNumber;
    private String type;
}
