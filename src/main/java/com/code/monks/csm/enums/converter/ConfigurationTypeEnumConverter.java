package com.code.monks.csm.enums.converter;

import com.code.monks.csm.enums.ConfigurationTypeEnum;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter
public class ConfigurationTypeEnumConverter implements AttributeConverter<ConfigurationTypeEnum, Integer> {

    @Override
    public Integer convertToDatabaseColumn(ConfigurationTypeEnum attribute) {
        return attribute != null ? attribute.getCode() : null;
    }

    @Override
    public ConfigurationTypeEnum convertToEntityAttribute(Integer dbData) {
        return dbData != null
                ? ConfigurationTypeEnum.fromCode(dbData)
                : null;
    }
}
