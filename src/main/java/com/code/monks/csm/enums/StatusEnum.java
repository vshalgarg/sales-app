package com.code.monks.csm.enums;

import lombok.Getter;

@Getter
public enum StatusEnum {
    ACTIVE(1),
    INACTIVE(2);

    private final int code;

    StatusEnum(int code){
        this.code=code;
    }

    public static StatusEnum fromCode(int code) {
        for (StatusEnum status : StatusEnum.values()) {
            if (status.code == code) {
                return status;
            }
        }
        throw new IllegalArgumentException("Invalid Status code: " + code);
    }
}
