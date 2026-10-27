package com.code.monks.csm.dto.request;

import java.util.List;

public record SendEmailRequestDTO(
        List<String> to,
        String subject,
        String html
) {}
