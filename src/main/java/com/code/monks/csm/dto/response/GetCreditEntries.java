package com.code.monks.csm.dto.response;

import com.code.monks.csm.entity.CreditEntryEntity;
import com.code.monks.csm.enums.CreditEntryEnum;
import com.code.monks.csm.utils.MoneyUtil;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDate;

@Data
@Builder
public class GetCreditEntries {

    private CreditEntryEnum paymentType;
    private String billNumber;
    private LocalDate date;
    private String referenceNumber;
    private LocalDate referenceDate;
    private Double receivedAmount;
    private String remark;
    private Integer supplierId;
    private Integer customerId;
    private String slipNumber;

    public static GetCreditEntries convertToGetCreditEntries(CreditEntryEntity creditEntry){
        return GetCreditEntries.builder()
                .paymentType(creditEntry.getPaymentType())
                .billNumber(creditEntry.getBillNumber())
                .date(creditEntry.getDate())
                .referenceNumber(creditEntry.getReferenceNumber())
                .referenceDate(creditEntry.getReferenceDate())
                .receivedAmount(MoneyUtil.toRupee(creditEntry.getReceivedAmount()).doubleValue())
                .remark(creditEntry.getRemark())
                .supplierId(creditEntry.getSupplierId())
                .customerId(creditEntry.getCustomerId())
                .slipNumber(creditEntry.getSlipNumber())
                .build();
    }

}
