package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;
import lombok.Getter;

@Getter
public class ResourceNotFoundException extends RuntimeException{

    private final ResponseErrorCode errorCode;

    public ResourceNotFoundException(ResponseErrorCode errorCode, String message){
        super(errorCode.getMessage() + message);
        this.errorCode = errorCode;
    }
}
