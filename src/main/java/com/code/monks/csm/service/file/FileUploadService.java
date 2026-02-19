package com.code.monks.csm.service.file;

import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface FileUploadService {

    List<String> uploadFiles(List<MultipartFile> images, String module);
}
