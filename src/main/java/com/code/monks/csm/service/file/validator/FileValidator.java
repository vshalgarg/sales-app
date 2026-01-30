package com.code.monks.csm.service.file.validator;

import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface FileValidator {
    void validate(List<MultipartFile> files);
}
