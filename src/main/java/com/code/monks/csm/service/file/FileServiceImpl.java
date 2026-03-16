package com.code.monks.csm.service.file;

import com.code.monks.csm.dto.response.FileUploadResponse;
import com.code.monks.csm.enums.ResponseErrorCode;
import com.code.monks.csm.enums.UploadModuleEnum;
import com.code.monks.csm.exception.FileUploadException;
import com.code.monks.csm.service.file.storage.FileStorage;
import com.code.monks.csm.service.file.validator.FileValidator;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class FileServiceImpl implements FileService {

    private final FileStorage fileStorage;

    @Override
    public List<FileUploadResponse> uploadFiles(List<MultipartFile> images, UploadModuleEnum uploadModule) {

        log.info("Starting image upload process");
        if (images == null || images.isEmpty()) {
            return new ArrayList<>();
        }

        List<FileUploadResponse> uploadedFiles = new ArrayList<>();
        for (MultipartFile image : images) {
            try {
                log.debug(
                        "Uploading image: name={}, size={} bytes, contentType={}",
                        image.getOriginalFilename(),
                        image.getSize(),
                        image.getContentType()
                );
                FileUploadResponse response =
                        fileStorage.store(image, uploadModule);
                uploadedFiles.add(response);

                log.debug("Image uploaded successfully. Key={}, Url={}",
                        response.getKey(),
                        response.getPublicUrl());

            } catch (Exception ex) {
                log.error(
                        "Image upload failed for file: {}",
                        image.getOriginalFilename(),
                        ex
                );
                throw new FileUploadException(ResponseErrorCode.FILE_UPLOAD_EXCEPTION);
            }
        }
        log.info("Successfully uploaded {} image(s) for module: {}",
                uploadedFiles.size(),
                uploadModule);

        return uploadedFiles;
    }

    @Override
    public void deleteFile(String key) {
        fileStorage.delete(key);
    }
}
