package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;

public class PermissionDeniedException extends RuntimeException{

    private final ResponseErrorCode errorCode;

    public PermissionDeniedException(ResponseErrorCode errorCode) {
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }

    public ResponseErrorCode getErrorCode() {
        return errorCode;
    }

    public int getCode() {
        return errorCode.getCode();
    }
}
