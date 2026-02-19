package com.code.monks.csm.service.file.storage;

import org.springframework.web.multipart.MultipartFile;

public interface FileStorage {

    String store(MultipartFile file, String module);
}
