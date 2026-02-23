package com.code.monks.csm.contoller;

import com.code.monks.csm.dataupload.FileProcessorService;
import com.code.monks.csm.dataupload.ProcessingSummary;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.IOException;
import java.util.concurrent.ExecutionException;

import static com.code.monks.csm.constants.ApiPaths.BASE;

@RequestMapping(BASE)
@RestController
public class TestController {

    @Autowired
    private FileProcessorService fileProcessorService;

    @GetMapping("/test")
    public ProcessingSummary testUplaod(@RequestParam("basePath") String basePath) throws IOException, ExecutionException, InterruptedException {
        return fileProcessorService.processFiles(basePath);

    }

}
