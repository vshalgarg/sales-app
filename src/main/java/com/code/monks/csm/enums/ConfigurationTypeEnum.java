package com.code.monks.csm.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ConfigurationTypeEnum {

    STRING(0),
    INTEGER(1),
    BOOLEAN(2);

    private final int code;

    public static ConfigurationTypeEnum fromCode(int code) {
        for (ConfigurationTypeEnum type : values()) {
            if (type.code == code) {
                return type;
            }
        }
        throw new IllegalArgumentException(
                "Unknown ConfigurationType code: " + code);
    }
}
