package com.code.monks.csm.enums.converter;

import com.code.monks.csm.enums.DrawTypeEnum;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter(autoApply = true)
public class DrawTypeEnumConverter implements AttributeConverter<DrawTypeEnum,Integer> {
    @Override
    public Integer convertToDatabaseColumn(DrawTypeEnum status) {
        return status != null ? status.getCode() : null;
    }

    @Override
    public DrawTypeEnum convertToEntityAttribute(Integer code) {
        return code != null ? DrawTypeEnum.fromCode(code) : null;
    }
}
