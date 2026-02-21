package com.code.monks.csm.service.file.storage;

import com.code.monks.csm.enums.UploadModuleEnum;
import org.springframework.web.multipart.MultipartFile;

public interface FileStorage {

    String store(MultipartFile file, UploadModuleEnum module);
}
