package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class DeleteStaffRequestDto {
    @NotNull(message = "Staff Id is required.")
    private int staffId;
}
