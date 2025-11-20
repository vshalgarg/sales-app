package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;

public class ExternalServiceException extends RuntimeException{

    private final ResponseErrorCode errorCode;

    public ExternalServiceException(ResponseErrorCode errorCode, String message){
        super(errorCode.getMessage() + message);
        this.errorCode = errorCode;
    }

    public ExternalServiceException(ResponseErrorCode errorCode, Throwable cause){
        super(errorCode.getMessage() + cause.getLocalizedMessage());
        this.errorCode = errorCode;
    }

    public int getCode(){
        return errorCode.getCode();
    }

}
