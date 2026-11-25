package com.code.monks.csm.service.impl;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring6.SpringTemplateEngine;
import java.util.Locale;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class EmailTemplateService {

    private final SpringTemplateEngine templateEngine;

    public String processTemplate(String templateName, Map<String, Object> variables) {
        Context context = new Context(Locale.forLanguageTag("en-IN"));
        context.setVariables(variables);
        return templateEngine.process(templateName, context);
    }
}

