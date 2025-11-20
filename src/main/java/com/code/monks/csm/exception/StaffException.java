package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;

public class StaffException extends RuntimeException{

    private final ResponseErrorCode errorCode;

    public StaffException(ResponseErrorCode errorCode, String st){
        super(errorCode.getMessage() + st);
        this.errorCode = errorCode;
    }

    public StaffException(ResponseErrorCode errorCode){
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }

    public int getCode(){
        return errorCode.getCode();
    }

}
