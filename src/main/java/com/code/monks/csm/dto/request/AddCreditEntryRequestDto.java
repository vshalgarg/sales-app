package com.code.monks.csm.dto.request;

import com.code.monks.csm.enums.CreditEntryEnum;
import com.code.monks.csm.enums.DrawTypeEnum;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class AddCreditEntryRequestDto {
    @NotNull(message = "Payment type is required")
    private CreditEntryEnum paymentType;

    private String billNumber;

    private LocalDate date;

    private String referenceNumber;

    @NotNull(message = "Reference date is required")
    private LocalDate referenceDate;

    private Double receivedAmount;

    private DrawTypeEnum drawType;
    private String remark;

    @NotNull(message = "Supplier is required")
    private Integer supplierId;

    @NotNull(message = "Customer is required")
    private Integer customerId;
    private String slipNumber;
}
