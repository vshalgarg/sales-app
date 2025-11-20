package com.code.monks.csm.enums;

import lombok.Getter;

@Getter
public enum CreditEntryEnum {
    CASH(1),
        CHEQUE(2),
            UPI(3);

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
