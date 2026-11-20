package com.code.monks.csm.service.impl;

import com.code.monks.csm.enums.ResponseErrorCode;
import com.code.monks.csm.exception.InvalidFileException;
import com.openhtmltopdf.pdfboxout.PdfRendererBuilder;
import org.springframework.stereotype.Service;
import java.io.ByteArrayOutputStream;

@Service
public class PdfGeneratorService {
    public byte[] generatePdf(String html) {
        try (ByteArrayOutputStream outputStream = new ByteArrayOutputStream()) {
            PdfRendererBuilder builder = new PdfRendererBuilder();
            builder.useFastMode();
            builder.useFont(() -> getClass().getResourceAsStream("/fonts/NotoSans-Regular.ttf"), "NotoSans");
            builder.withHtmlContent(html, null);
            builder.toStream(outputStream);
            builder.run();
            return outputStream.toByteArray();
        } catch (Exception exception) {
            throw new InvalidFileException(ResponseErrorCode.INVALID_FILE_FOUND);
        }
    }
}
