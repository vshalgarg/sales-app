package com.code.monks.csm.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class BillEntryRequestDto {

    @NotNull(message = "Date must not be empty")
    private LocalDate date;

    @NotNull(message = "Received date must not be empty")
    private LocalDate receivedDate;

    @NotBlank(message = "order is required")
    private String order;

    @NotNull(message = "Pieces are required")
    private int pieces;

    @NotNull(message = "Gross amount is required")
    private double grossAmount;

//    @NotNull(message = "Discount percent is required")
    private float discountPercent;

//    @NotNull(message = "Discount account is required")
    private double discountAmount;

    @NotNull(message = "Gst percent is required")
    private float gstPercent;

    @NotNull(message = "Gst amount is required")
    private double gstAmount;

    @NotNull(message = "Bill amount is required")
    private double billAmount;

//    @NotNull(message = "Add on amount is required")
    private double addOnAmount;

    @NotNull(message = "ECR Amount is required")
    private double ecrAmount;

    @NotNull(message = "Taxable value is required")
    private double taxableValue;

    @NotBlank(message = "Transport is required")
    private String transport;

    @NotBlank(message = "LR Number is required")
    private String lrNumber;

    private String remarks;

    private int supplierId;

    private int customerId;
}
