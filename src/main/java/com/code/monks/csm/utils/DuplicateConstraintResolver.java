package com.code.monks.csm.utils;

import com.code.monks.csm.exception.DuplicateEntryException;
import org.hibernate.exception.ConstraintViolationException;
import org.springframework.dao.DataIntegrityViolationException;

import java.util.Map;

import static com.code.monks.csm.enums.ResponseErrorCode.DUPLICATE_ENTRY;

public final class DuplicateConstraintResolver {

    private static final Map<String, String> CONSTRAINT_MESSAGES = Map.of(
            "uk_transports_name", "Transport name already exists",
            "uk_transports_email", "Email already exists",
            "uk_transports_gst", "GST number already exists",
            "uk_tc_transport_contact", "Contact number already exists for this transport"
    );

    private DuplicateConstraintResolver() {
    }

    public static void handle(DataIntegrityViolationException ex) {

        String message = "Duplicate entry";

        Throwable t = ex;
        while (t != null) {
            if (t instanceof ConstraintViolationException cve) {
                String constraint = cve.getConstraintName();
                message = CONSTRAINT_MESSAGES.getOrDefault(constraint, message);
                break;
            }
            t = t.getCause();
        }

        throw new DuplicateEntryException(DUPLICATE_ENTRY, message);
    }
}
