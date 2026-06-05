package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;
import lombok.Getter;

@Getter
public class BusinessException extends RuntimeException {
    private final ResponseErrorCode errorCode;

    public BusinessException(ResponseErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }
}