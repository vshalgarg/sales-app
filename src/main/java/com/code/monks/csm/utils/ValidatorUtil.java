package com.code.monks.csm.utils;

import com.code.monks.csm.exception.DuplicateEntryException;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.function.BooleanSupplier;

import static com.code.monks.csm.enums.ResponseErrorCode.DUPLICATE_ENTRY;

@Component
@AllArgsConstructor
public class ValidatorUtil {

    public void validateUniqueFields(List<DuplicateCheck> checks) {
        List<String> duplicates = new ArrayList<>();

        for (DuplicateCheck check : checks) {
            addIfDuplicate(check.getCondition().getAsBoolean(), check.getFieldName(), duplicates);
        }

        if (!duplicates.isEmpty()) {
            throw new DuplicateEntryException(DUPLICATE_ENTRY, formatConflictMessage(duplicates));
        }
    }

    private void addIfDuplicate(boolean exists, String fieldName, List<String> duplicates) {
        if (exists) {
            duplicates.add(fieldName);
        }
    }

    private String formatConflictMessage(List<String> fields) {
        return "Duplicate entry found for: " + String.join(", ", fields);
    }

    public static class DuplicateCheck {
        private final String fieldName;
        private final BooleanSupplier condition;

        public DuplicateCheck(String fieldName, BooleanSupplier condition) {
            this.fieldName = fieldName;
            this.condition = condition;
        }

        public String getFieldName() {
            return fieldName;
        }

        public BooleanSupplier getCondition() {
            return condition;
        }
    }

}
