package com.code.monks.csm.service.file.storage;

import com.code.monks.csm.dto.response.FileUploadResponse;
import com.code.monks.csm.enums.UploadModuleEnum;
import com.code.monks.csm.exception.FileUploadException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import static com.code.monks.csm.enums.ResponseErrorCode.FILE_STORAGE_FAILED;

@Service
@Slf4j
@RequiredArgsConstructor
public class FileStorageImpl implements FileStorage {

    private final S3Client s3Client;

    @Value("${e2e.s3.endpoint}")
    private String endpoint;

    @Value("${e2e.s3.bucket-name}")
    private String bucketName;

    @Override
    public FileUploadResponse store(MultipartFile file, UploadModuleEnum uploadModule) {

        try {
            log.debug("Starting upload for file: {}", file.getOriginalFilename());

            String originalName = file.getOriginalFilename();
            String extension = originalName.substring(originalName.lastIndexOf("."));

            LocalDateTime now = LocalDateTime.now();
            String year = now.format(DateTimeFormatter.ofPattern("yyyy"));
            String month = now.format(DateTimeFormatter.ofPattern("MM"));
            String timestamp = now.format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmssSSS"));

            String fileName = year + "/" +
                    month + "/" +
                    uploadModule.getFolder() + "/" +
                    timestamp + extension;

            PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                    .bucket(bucketName)
                    .key(fileName)
                    .contentType(file.getContentType())
                    .build();

            s3Client.putObject(
                    putObjectRequest,
                    RequestBody.fromInputStream(file.getInputStream(), file.getSize())
            );

            String publicUrl = getPublicUrl(fileName);

            log.info("File uploaded successfully. Key: {}, URL: {}", fileName, publicUrl);

            return new FileUploadResponse(fileName, publicUrl);

        } catch (Exception ex) {
            log.error("Upload failed. Bucket: {}, Endpoint issue possible.", bucketName);
            log.error("Error message: {}", ex.getMessage());
            throw new FileUploadException(FILE_STORAGE_FAILED);
        }
    }

    @Override
    public void delete(String key) {
        try {
            s3Client.deleteObject(builder ->
                    builder.bucket(bucketName)
                            .key(key)
            );
            log.info("File deleted from storage. Key={}", key);
        } catch (Exception ex) {
            log.error("File delete failed for key={}", key);
            throw new FileUploadException(FILE_STORAGE_FAILED);
        }
    }

    private String getPublicUrl(String key) {
        return endpoint + "/" + bucketName + "/" + key;
    }
}