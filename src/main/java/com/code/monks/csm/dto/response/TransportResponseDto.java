package com.code.monks.csm.dto.response;

import com.code.monks.csm.enums.StatusEnum;
import lombok.Data;

import java.util.List;

@Data
public class TransportResponseDto {

    private Integer id;
    private String name;
    private String email;
    private String gstNo;

    private String state;
    private String city;
    private String addressLine1;
    private String addressLine2;

    private StatusEnum status;

    private List<TransportContactResponseDto> contacts;
}
