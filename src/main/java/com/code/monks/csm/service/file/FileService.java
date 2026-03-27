package com.code.monks.csm.service.file;

import com.code.monks.csm.dto.response.FileUploadResponse;
import com.code.monks.csm.enums.UploadModuleEnum;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface FileService {

    List<FileUploadResponse> uploadFiles(List<MultipartFile> images, UploadModuleEnum uploadModule);
    void deleteFile(String key);
}
