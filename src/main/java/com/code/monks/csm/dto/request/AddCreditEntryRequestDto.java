package com.code.monks.csm.dto.request;

import com.code.monks.csm.enums.CreditEntryEnum;
import com.code.monks.csm.enums.DrawTypeEnum;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class AddCreditEntryRequestDto {
    @NotNull(message = "Payment type is required")
    private CreditEntryEnum paymentType;

    @NotBlank(message = "Bill number is required")
    private String billNumber;

    @NotNull(message = "Date is required")
    private LocalDate date;

    @NotNull(message = "Cheque number is required")
    private String chequeNumber;

    @NotNull(message = "Cheque date is required")
    private LocalDate chequeDate;

    @NotNull(message = "Received amount is required")
    private Double receivedAmount;

    @NotNull(message = "Supplier current balance is required")
    private Double supplierCurrentBalance;

    @NotNull(message = "Customer current balance is required")
    private Double customerCurrentBalance;

    private DrawTypeEnum drawType;

    private String remark;

    private Integer supplierId;

    private Integer customerId;
}
