package com.code.monks.csm.service.file;

import com.code.monks.csm.enums.UploadModuleEnum;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface FileUploadService {

    List<String> uploadFiles(List<MultipartFile> images, UploadModuleEnum uploadModule);
}
