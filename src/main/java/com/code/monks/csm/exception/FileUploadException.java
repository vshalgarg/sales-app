package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;
import lombok.Getter;

@Getter
public class FileUploadException extends RuntimeException{

    private ResponseErrorCode errorCode;
    public FileUploadException(ResponseErrorCode errorCode){
        super(errorCode.getMessage());
        this.errorCode= errorCode;
    }
}
