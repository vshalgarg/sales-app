package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;

public class DuplicateEntryException extends RuntimeException{
    private final ResponseErrorCode errorCode;

    public DuplicateEntryException(ResponseErrorCode errorCode, String st){
        super(errorCode.getMessage()+st);
        this.errorCode=errorCode;
    }

    public int getCode(){
        return errorCode.getCode();
    }
}
