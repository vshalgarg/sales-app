package com.code.monks.csm.enums.converter;

import io.micrometer.common.util.StringUtils;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter(autoApply = true)
public class EmptyStringToNullConverter
        implements AttributeConverter<String, String> {

    @Override
    public String convertToDatabaseColumn(String value) {
        return StringUtils.isBlank(value) ? null : value;
    }

    @Override
    public String convertToEntityAttribute(String value) {
        return value;
    }
}
