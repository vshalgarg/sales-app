package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.response.TransportContactResponseDto;
import com.code.monks.csm.dto.response.TransportDetailsResponseDTO;
import com.code.monks.csm.entity.TransportContactEntity;
import com.code.monks.csm.entity.TransportEntity;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

public class TransportMapper {

    public static TransportDetailsResponseDTO toResponse(
            TransportEntity entity
    ) {

        return TransportDetailsResponseDTO.builder()
                .id(entity.getId())
                .name(entity.getName())
                .email(entity.getEmail())
                .gstNo(entity.getGstNo())
                .state(entity.getState())
                .city(entity.getCity())
                .pinCode(entity.getPinCode())
                .addressLine1(entity.getAddressLine1())
                .addressLine2(entity.getAddressLine2())
                .status(
                        entity.getStatus() != null
                                ? entity.getStatus().name()
                                : null
                )
                .contacts(
                        mapContacts(entity.getContacts())
                )
                .build();
    }

    private static List<TransportContactResponseDto> mapContacts(
            List<TransportContactEntity> contacts
    ) {

        if (contacts == null) {
            return Collections.emptyList();
        }
        return contacts.stream()
                .map(contact ->
                        TransportContactResponseDto.builder()
                                .contactPerson(contact.getContactPerson())
                                .contactNumber(contact.getContactNumber())
                                .type(contact.getType())
                                .build()
                )
                .collect(Collectors.toList());
    }
}
