package com.code.monks.csm.enums.converter;

import com.code.monks.csm.enums.StatusEnum;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter(autoApply = true)
public class StatusEnumConverter implements AttributeConverter<StatusEnum,Integer> {

    @Override
    public Integer convertToDatabaseColumn(StatusEnum status) {
        return status != null ? status.getCode() : null;
    }

    @Override
    public StatusEnum convertToEntityAttribute(Integer code) {
        return code != null ? StatusEnum.fromCode(code) : null;
    }
}
