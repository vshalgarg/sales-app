package com.code.monks.csm.enums.converter;

import com.code.monks.csm.enums.CreditEntryEnum;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter(autoApply = true)
public class CreditEntryEnumConverter implements AttributeConverter<CreditEntryEnum,Integer> {
    @Override
    public Integer convertToDatabaseColumn(CreditEntryEnum attribute) {
        return attribute != null ? attribute.getCode() : null;
    }

    @Override
    public CreditEntryEnum convertToEntityAttribute(Integer dbData) {
        return dbData != null ? CreditEntryEnum.fromCode(dbData) : null;
    }
}
