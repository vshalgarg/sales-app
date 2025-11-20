package com.code.monks.csm.enums.converter;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

import java.util.Arrays;
import java.util.stream.Collectors;

@Converter(autoApply = true)
public class StringArrayConverter implements AttributeConverter<String[], String> {

    @Override
    public String convertToDatabaseColumn(String[] attribute) {
        if (attribute == null || attribute.length == 0) {
            return null;
        }
        return Arrays.stream(attribute)
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.joining(",")); // store as comma-separated
    }

    @Override
    public String[] convertToEntityAttribute(String dbData) {
        try {
            if (dbData == null || dbData.trim().isEmpty() || dbData.equalsIgnoreCase("null")) {
                return new String[0];
            }

            // Clean unexpected brackets or quotes
            String cleaned = dbData.trim()
                    .replace("[", "")
                    .replace("]", "")
                    .replace("\"", "");

            // Handle stray commas gracefully
            return Arrays.stream(cleaned.split("\\s*,\\s*"))
                    .filter(s -> !s.isEmpty())
                    .toArray(String[]::new);

        } catch (Exception e) {
            System.err.println("⚠️ Converter error: invalid DB value for preferred_transport = " + dbData);
            return new String[0];
        }
    }
}
