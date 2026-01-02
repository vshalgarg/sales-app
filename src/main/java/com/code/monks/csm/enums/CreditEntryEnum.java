package com.code.monks.csm.enums;

import lombok.Getter;

@Getter
public enum CreditEntryEnum {
    NEFT_RTGS(1),
    UPI(2),
    CASH(3),
    CHEQUE(4);

    private final int code;

    CreditEntryEnum(int code){
        this.code=code;
    }

    public static CreditEntryEnum fromCode(int code){
        for(CreditEntryEnum creditEntryEnum : CreditEntryEnum.values()){
            if(creditEntryEnum.code == code){
                return creditEntryEnum;
            }
        }
        throw new IllegalArgumentException("Invalid Status code: " + code);
    }
}
