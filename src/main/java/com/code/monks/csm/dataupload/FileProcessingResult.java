package com.code.monks.csm.dataupload;

import java.util.List;

public class FileProcessingResult {

    private final String fileName;
    private final List<ErrorDto> errors;

    public FileProcessingResult(String fileName, List<ErrorDto> errors) {
        this.fileName = fileName;
        this.errors = errors;
    }

    public String getFileName() {
        return fileName;
    }

    public List<ErrorDto> getErrors() {
        return errors;
    }
}
