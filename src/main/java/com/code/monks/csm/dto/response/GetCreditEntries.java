package com.code.monks.csm.dto.response;

import com.code.monks.csm.entity.CreditEntryEntity;
import com.code.monks.csm.enums.CreditEntryEnum;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class GetCreditEntries {

    private CreditEntryEnum paymentType;
    private String billNumber;
    private LocalDate date;
    private String chequeNumber;
    private LocalDate chequeDate;
    private Double receivedAmount;
    private Double supplierCurrentBalance;
    private Double customerCurrentBalance;
    private String remark;
    private Integer supplierId;
    private Integer customerId;

    public static GetCreditEntries convertToGetCreditEntries(CreditEntryEntity creditEntry){
        return GetCreditEntries.builder()
                .paymentType(creditEntry.getPaymentType())
                .billNumber(creditEntry.getBillNumber())
                .date(creditEntry.getDate())
                .chequeNumber(creditEntry.getChequeNumber())
                .chequeDate(creditEntry.getChequeDate())
                .receivedAmount(creditEntry.getReceivedAmount() / 100.0)
                .supplierCurrentBalance(creditEntry.getSupplierCurrentBalance() / 100.0)
                .customerCurrentBalance(creditEntry.getCustomerCurrentBalance() / 100.0)
                .remark(creditEntry.getRemark())
                .supplierId(creditEntry.getSupplierId())
                .customerId(creditEntry.getCustomerId())
                .build();
    }

}
