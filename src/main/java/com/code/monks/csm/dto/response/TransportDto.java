package com.code.monks.csm.dto.response;

import com.code.monks.csm.enums.StatusEnum;
import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TransportDto {
    private Integer id;
    private String name;
    private String gstNo;
    private String contactNumber;
    private String city;
    private String address;
    private StatusEnum status;
}
