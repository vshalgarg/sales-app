package com.code.monks.csm.dto.request;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ContactRequestDto {
    private String contactPerson;
    private String mobileNumber;
    private String type;
}
