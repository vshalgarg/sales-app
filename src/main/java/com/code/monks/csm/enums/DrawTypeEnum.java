package com.code.monks.csm.enums;

import lombok.Getter;

@Getter
public enum DrawTypeEnum {
    DRAW(1),
    CHEQUE(2);

    private final int code;

    DrawTypeEnum(int code){
        this.code=code;
    }

    public static DrawTypeEnum fromCode(int code){
        for (DrawTypeEnum status : DrawTypeEnum.values()) {
            if (status.code == code) {
                return status;
            }
        }
        throw new IllegalArgumentException("Invalid Status code: " + code);
    }
}
