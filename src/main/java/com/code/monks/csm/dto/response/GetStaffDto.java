package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class GetStaffDto {
    private int staffId;
    private String staffName;
    private String phone;
    private LocalDate joiningDate;
}
