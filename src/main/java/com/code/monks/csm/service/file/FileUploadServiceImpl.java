package com.code.monks.csm.service.file;

import com.code.monks.csm.enums.ResponseErrorCode;
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
public class FileUploadServiceImpl implements FileUploadService {

    private final FileValidator fileValidator;
    private final FileStorage fileStorage;

    @Override
    public List<String> uploadFiles(List<MultipartFile> images) {

        log.info("Starting image upload process");
        fileValidator.validate(images);
        List<String> imageUrls = new ArrayList<>();
        if (images == null || images.isEmpty()) {
            log.debug("Validating bill images");
            return imageUrls;
        }
        for (MultipartFile image : images) {
            try {
                log.debug(
                        "Uploading image: name={}, size={} bytes, contentType={}",
                        image.getOriginalFilename(),
                        image.getSize(),
                        image.getContentType()
                );
                String url = fileStorage.store(image);
                imageUrls.add(url);

                log.debug("Image uploaded successfully. Stored at: {}", url);

            } catch (Exception ex) {
                log.error(
                        "Image upload failed for file: {}",
                        image.getOriginalFilename(),
                        ex
                );
                throw new FileUploadException(ResponseErrorCode.FILE_UPLOAD_EXCEPTION);
            }
        }
        log.info("Successfully uploaded {} image(s)", imageUrls.size());
        return imageUrls;
    }
}
