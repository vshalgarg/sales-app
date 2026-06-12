package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;
import lombok.Getter;

@Getter
public class ExcelGenerationException extends RuntimeException{

    private final ResponseErrorCode responseErrorCode;

    public ExcelGenerationException(ResponseErrorCode responseErrorCode, Throwable cause) {
        super(responseErrorCode.getMessage(), cause);
        this.responseErrorCode = responseErrorCode;
    }

    public int getCode() {
        return responseErrorCode.getCode();
    }
}
