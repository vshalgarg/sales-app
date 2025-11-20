package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;

public class CustomerException extends RuntimeException{
    private final ResponseErrorCode errorCode;

    public CustomerException(ResponseErrorCode errorCode, String st){
        super(errorCode.getMessage()+st);
        this.errorCode=errorCode;
    }

    public int getCode(){
        return errorCode.getCode();
    }
}
