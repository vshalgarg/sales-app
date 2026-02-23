package com.code.monks.csm.dataupload;

import java.util.List;
import java.util.Map;

public class ProcessingSummary {

    private final Map<String, List<ErrorDto>> errorMap;
    private final List<String> successFiles;

    public ProcessingSummary(Map<String, List<ErrorDto>> errorMap,
                             List<String> successFiles) {
        this.errorMap = errorMap;
        this.successFiles = successFiles;
    }

    public Map<String, List<ErrorDto>> getErrorMap() {
        return errorMap;
    }

    public List<String> getSuccessFiles() {
        return successFiles;
    }
}