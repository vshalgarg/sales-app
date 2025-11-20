package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;
import lombok.Getter;

@Getter
public class SupplierException extends RuntimeException{
    private final ResponseErrorCode errorCode;

    public SupplierException(ResponseErrorCode errorCode,String st){
        super(errorCode.getMessage()+st);
        this.errorCode=errorCode;
    }
}
