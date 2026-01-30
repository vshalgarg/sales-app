package com.code.monks.csm.service.file.validator;

import com.code.monks.csm.exception.InvalidFileException;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

import static com.code.monks.csm.enums.ResponseErrorCode.INVALID_FILE_FOUND;

@Component
public class FileValidatorImpl implements FileValidator{

    private static final int MAX_FILES = 2;

    @Override
    public void validate(List<MultipartFile> files) {

        if (files == null || files.isEmpty()) {
            return;
        }
        if (files.size() > MAX_FILES) {
            throw new InvalidFileException(INVALID_FILE_FOUND);
        }
    }
}
