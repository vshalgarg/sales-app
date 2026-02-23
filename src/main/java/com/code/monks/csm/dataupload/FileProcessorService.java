package com.code.monks.csm.dataupload;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.*;
import java.util.stream.Stream;

@Service
@Slf4j
public class FileProcessorService {

    @Autowired
    private XlsxReader xlsxReader;

    public ProcessingSummary processFiles(String basePath) throws IOException, ExecutionException, InterruptedException {
        Path directoryPath = Paths.get(basePath);

        if (!Files.isDirectory(directoryPath)) {
            throw new IllegalArgumentException("Invalid directory path: " + basePath);
        }

        ExecutorService executor = Executors.newFixedThreadPool(8);

        List<Future<FileProcessingResult>> futures = new ArrayList<>();

        try (Stream<Path> paths = Files.list(directoryPath)) {

            paths.filter(Files::isRegularFile)
                    .forEach(path -> {
                        Callable<FileProcessingResult> task = () -> {
                            File file = path.toFile();
                            List<ErrorDto> errors = xlsxReader.readXlsx(file);
                            return new FileProcessingResult(file.getName(), errors);
                        };
                        futures.add(executor.submit(task));
                    });
        }

        Map<String, List<ErrorDto>> errorMap = new HashMap<>();
        List<String> successFiles = new ArrayList<>();

        for (Future<FileProcessingResult> future : futures) {
            FileProcessingResult result = future.get();

            errorMap.put(result.getFileName(), result.getErrors());

            if (result.getErrors().isEmpty()) {
                successFiles.add(result.getFileName());
            }
        }

        executor.shutdown();

        return new ProcessingSummary(errorMap, successFiles);
    }

}
