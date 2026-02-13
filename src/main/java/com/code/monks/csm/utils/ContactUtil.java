package com.code.monks.csm.utils;

import com.code.monks.csm.dto.request.ContactRequestDto;
import com.code.monks.csm.entity.CustomerEntity;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Component
public class ContactUtil {

    public static <T> List<ContactRequestDto> mapContacts(
            List<T> contacts,
            Function<T, String> contactPersonGetter,
            Function<T, String> mobileGetter,
            Function<T, String> typeGetter) {

        if (contacts == null || contacts.isEmpty()) {
            return Collections.emptyList();
        }

        return contacts.stream()
                .map(contact -> ContactRequestDto.builder()
                        .contactPerson(contactPersonGetter.apply(contact))
                        .mobileNumber(mobileGetter.apply(contact))
                        .type(typeGetter.apply(contact))
                        .build())
                .collect(Collectors.toList());
    }

    public static String formatAddress(String line1, String line2) {
        return Stream.of(line1, line2)
                .filter(Objects::nonNull)
                .filter(s -> !s.trim().isEmpty())
                .collect(Collectors.joining(", "));
    }
}
