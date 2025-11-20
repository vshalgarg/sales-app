package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;
import lombok.Getter;

@Getter
public class CreditException extends RuntimeException{
    private final ResponseErrorCode errorCode;

    public CreditException(ResponseErrorCode errorCode,String st){
        super(errorCode.getMessage()+st);
        this.errorCode = errorCode;
    }

}
