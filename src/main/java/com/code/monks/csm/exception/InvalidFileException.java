package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;
import lombok.Getter;

@Getter
public class InvalidFileException extends RuntimeException{

    private ResponseErrorCode errorCode;
    public InvalidFileException(ResponseErrorCode errorCode){
        super(errorCode.getMessage());
        this.errorCode = errorCode;
    }
}
