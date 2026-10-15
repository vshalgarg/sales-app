package com.code.monks.csm.dto.email;



import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.math.BigInteger;
import java.time.LocalDate;
@AllArgsConstructor
@Getter
@Setter
public class DailySalesReportDto {

    private LocalDate reportDate;
    private BigInteger totalCreditAmount;
    private long totalBills;
    private long totalCredits;
    private long totalRetailers;
    private long totalSuppliers;
    private long totalCustomers;
}

