package com.code.monks.csm.service.file.storage;

import com.code.monks.csm.exception.FileUploadException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

import static com.code.monks.csm.enums.ResponseErrorCode.FILE_STORAGE_FAILED;

@Service
@Slf4j
public class FileStorageImpl implements FileStorage{

    private static final String BASE_UPLOAD_DIR = "uploads/bills";

    @Override
    public String store(MultipartFile file) {

        try {
            log.debug("Storing file: {}", file.getOriginalFilename());
            String originalName = file.getOriginalFilename();
            String extension = originalName.substring(originalName.lastIndexOf("."));
            String fileName = UUID.randomUUID() + extension;

            Path uploadDir = Paths.get(BASE_UPLOAD_DIR);
            Files.createDirectories(uploadDir);

            Path targetPath = uploadDir.resolve(fileName);

            Files.copy(
                    file.getInputStream(),
                    targetPath,
                    StandardCopyOption.REPLACE_EXISTING
            );

            log.info("File stored successfully at {}", targetPath);
            return targetPath.toString();
        } catch (Exception ex) {
            log.error("Failed to store file: {}", file.getOriginalFilename(), ex);
            throw new FileUploadException(FILE_STORAGE_FAILED);
        }
    }
}
