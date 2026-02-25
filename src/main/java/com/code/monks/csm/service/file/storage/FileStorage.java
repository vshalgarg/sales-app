package com.code.monks.csm.service.file.storage;

import com.code.monks.csm.dto.response.FileUploadResponse;
import com.code.monks.csm.enums.UploadModuleEnum;
import org.springframework.web.multipart.MultipartFile;

public interface FileStorage {

    FileUploadResponse store(MultipartFile file, UploadModuleEnum module);
    void delete(String key);
}
