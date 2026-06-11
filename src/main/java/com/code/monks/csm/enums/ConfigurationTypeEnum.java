package com.code.monks.csm.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum ConfigurationTypeEnum {

    STRING(0) {
        @Override
        public boolean isValid(String value) {
            return true;
        }
    },

    INTEGER(1) {
        @Override
        public boolean isValid(String value) {
            try {
                Integer.parseInt(value);
                return true;
            } catch (NumberFormatException ex) {
                return false;
            }
        }
    },

    BOOLEAN(2) {
        @Override
        public boolean isValid(String value) {
            return "true".equalsIgnoreCase(value)
                    || "false".equalsIgnoreCase(value);
        }
    };

    private final int code;

    public abstract boolean isValid(String value);

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