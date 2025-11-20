package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;

public class BillException extends RuntimeException{
    private final ResponseErrorCode errorCode;

    public BillException(ResponseErrorCode errorCode, String st){
        super(errorCode.getMessage()+st);
        this.errorCode = errorCode;
    }

    public int getCode(){
        return errorCode.getCode();
    }
}
