package com.code.monks.csm.dto.request;

import com.code.monks.csm.enums.StatusEnum;
import lombok.Data;

@Data
public class UpdateTransportRequest {

    private Integer id;
    private String name;
    private String gstNo;
    private String contactNumber;
    private String city;
    private String address;
    private StatusEnum status;
}
