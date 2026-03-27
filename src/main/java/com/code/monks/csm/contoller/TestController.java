package com.code.monks.csm.contoller;

import com.code.monks.csm.dataupload.FileProcessorService;
import com.code.monks.csm.dataupload.ProcessingSummary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.concurrent.ExecutionException;

import static com.code.monks.csm.constants.ApiPaths.BASE;

@RequestMapping(BASE)
@RestController
public class TestController {

    @Autowired
    private FileProcessorService fileProcessorService;

    @GetMapping("/uploaddata")
    public ProcessingSummary testUplaod(@RequestParam("basePath") String basePath) throws IOException, ExecutionException, InterruptedException {
        return fileProcessorService.processFiles(basePath);

    }


    @GetMapping("/createMetadata")
    public ResponseEntity<InputStreamResource> createMetadata(@RequestParam("basePath") String basePath) throws IOException, ExecutionException, InterruptedException {
        try {
            String json = fileProcessorService.createMetadata(basePath); // your existing method

            // ✅ extract folder name
            String folderName = Paths.get(basePath)
                    .getFileName()
                    .toString();

            String fileName = folderName + ".json";

            InputStreamResource resource =
                    new InputStreamResource(new ByteArrayInputStream(json.getBytes()));

            return ResponseEntity.ok()
                    .contentType(MediaType.APPLICATION_JSON)
                    .header(HttpHeaders.CONTENT_DISPOSITION,
                            "attachment; filename=\"" + fileName + "\"")
                    .body(resource);

        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
