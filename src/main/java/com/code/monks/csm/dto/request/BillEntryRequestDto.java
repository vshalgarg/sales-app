package com.code.monks.csm.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
public class BillEntryRequestDto {

    @NotNull(message = "Date must not be empty")
    private LocalDate date;

    private LocalDate receivedDate;

    @NotBlank(message = "order is required")
    private String order;

    private int supplierId;
    private int customerId;

    private Integer transportId;
    private String transportName;
    private String lrNumber;
    private String remarks;

    private BigDecimal taxableValue;
    private BigDecimal billAmount;

    @NotEmpty(message = "At least one bill item is required")
    @Valid
    private List<BillItemRequestDto> billItems;
}
