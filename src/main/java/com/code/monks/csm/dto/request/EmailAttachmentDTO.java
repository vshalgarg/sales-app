package com.code.monks.csm.dto.request;

public record EmailAttachmentDTO(
        String fileName,
        String contentType,
        String content
) { }