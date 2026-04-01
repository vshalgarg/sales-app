package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.request.AddSupplierRequestDto;
import com.code.monks.csm.dto.request.ContactRequestDto;
import com.code.monks.csm.dto.request.UpdateSupplierRequestDto;
import com.code.monks.csm.dto.response.GetSupplierByIdResponseDto;
import com.code.monks.csm.dto.response.SupplierListResponseDto;
import com.code.monks.csm.dto.response.SupplierSummaryDto;
import com.code.monks.csm.dto.response.TransportDto;
import com.code.monks.csm.entity.ContactEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.utils.ContactUtil;
import org.springframework.stereotype.Component;
import org.apache.commons.lang3.StringUtils;

import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Component
public class SupplierMapper {

    // add
    public SupplierEntity toEntity(AddSupplierRequestDto dto, String code) {

        SupplierEntity entity = new SupplierEntity();

        entity.setCode(code);
        entity.setSupplierName(dto.getSupplierName());
        entity.setEmail(dto.getEmail());

        entity.setGroupName(
                StringUtils.isBlank(dto.getSupplierGroup())
                        ? dto.getSupplierName()
                        : dto.getSupplierGroup()
        );

        entity.setGstNo(dto.getSupplierGstNo());
        entity.setCommissionScheme(dto.getCommissionScheme());
        entity.setCommissionRate(dto.getCommissionRate());
        entity.setReferenceBy(dto.getReferenceBy());

        entity.setAddressLine1(dto.getAddressLine1());
        entity.setAddressLine2(dto.getAddressLine2());
        entity.setState(dto.getState());
        entity.setCity(dto.getCity());
        entity.setPinCode(dto.getPinCode());

        entity.setMsme(
                StringUtils.isBlank(dto.getSupplierMsme())
                        ? "SMALL"
                        : dto.getSupplierMsme()
        );

        entity.setRemark(dto.getRemark());

        entity.setBankName(dto.getBankName());
        entity.setIfscCode(dto.getIfscCode());
        entity.setBranchName(dto.getBranchName());
        entity.setAccountName(dto.getAccountName());
        entity.setAccountNumber(dto.getAccountNumber());
        entity.setStatus(StatusEnum.ACTIVE);

        if (dto.getContacts() != null) {
            List<ContactEntity> contacts = dto.getContacts().stream()
                    .map(c -> {
                        ContactEntity contact = new ContactEntity();
                        contact.setContactPerson(c.getContactPerson());
                        contact.setMobileNumber(c.getMobileNumber());
                        contact.setType(c.getType());
                        contact.setSupplier(entity);
                        return contact;
                    })
                    .collect(Collectors.toList());

            entity.setContactList(contacts);
        }

        return entity;
    }

    // update
    public void updateEntity(SupplierEntity entity, UpdateSupplierRequestDto dto) {

        entity.setSupplierName(dto.getSupplierName());
        entity.setEmail(dto.getEmail());

        entity.setGroupName(
                StringUtils.isBlank(dto.getGroupName())
                        ? dto.getSupplierName()
                        : dto.getGroupName()
        );

        entity.setGstNo(dto.getGstNo());
        entity.setCommissionScheme(dto.getCommissionScheme());
        entity.setCommissionRate(dto.getCommissionRate());
        entity.setReferenceBy(dto.getReferenceBy());

        entity.setAddressLine1(dto.getAddressLine1());
        entity.setAddressLine2(dto.getAddressLine2());
        entity.setState(dto.getState());
        entity.setCity(dto.getCity());
        entity.setPinCode(dto.getPinCode());

        entity.setMsme(
                StringUtils.isBlank(dto.getMsme())
                        ? "SMALL"
                        : dto.getMsme()
        );

        entity.setRemark(dto.getRemark());

        entity.setBankName(dto.getBankName());
        entity.setIfscCode(dto.getIfscCode());
        entity.setBranchName(dto.getBranchName());
        entity.setAccountName(dto.getAccountName());
        entity.setAccountNumber(dto.getAccountNumber());

        if (dto.getContacts() != null) {
            entity.getContactList().clear();

            List<ContactEntity> contacts = dto.getContacts().stream()
                    .map(c -> {
                        ContactEntity contact = new ContactEntity();
                        contact.setContactPerson(c.getContactPerson());
                        contact.setMobileNumber(c.getMobileNumber());
                        contact.setType(c.getType());
                        contact.setSupplier(entity);
                        return contact;
                    })
                    .toList();

            entity.getContactList().addAll(contacts);
        }
    }

    public GetSupplierByIdResponseDto toResponse(SupplierEntity entity) {

        List<ContactRequestDto> contacts = ContactUtil.mapContacts(
                entity.getContactList(),
                ContactEntity::getContactPerson,
                ContactEntity::getMobileNumber,
                ContactEntity::getType
        );

        List<TransportDto> transportDtos = Optional.ofNullable(entity.getPreferredTransports())
                .orElse(Collections.emptySet())
                .stream()
                .map(t -> TransportDto.builder()
                        .id(t.getId())
                        .name(t.getName())
                        .build())
                .toList();

        return GetSupplierByIdResponseDto.builder()
                .id(entity.getId())
                .code(entity.getCode())
                .supplierName(entity.getSupplierName())
                .email(entity.getEmail())
                .groupName(entity.getGroupName())
                .gstNo(entity.getGstNo())
                .commissionScheme(entity.getCommissionScheme())
                .commissionRate(entity.getCommissionRate())
                .referenceBy(entity.getReferenceBy())
                .addressLine1(entity.getAddressLine1())
                .addressLine2(entity.getAddressLine2())
                .state(entity.getState())
                .city(entity.getCity())
                .pinCode(entity.getPinCode())
                .msme(entity.getMsme())

                // bank details
                .bankName(entity.getBankName())
                .ifscCode(entity.getIfscCode())
                .branchName(entity.getBranchName())
                .accountName(entity.getAccountName())
                .accountNumber(entity.getAccountNumber())

                .remark(entity.getRemark())
                .status(entity.getStatus())
                .contacts(contacts)
                .preferredTransports(transportDtos)
                .build();
    }

    public SupplierListResponseDto toListDto(SupplierEntity record) {

        String mobile = Optional.ofNullable(record.getContactList())
                .orElse(Collections.emptyList())
                .stream()
                .findFirst()
                .map(ContactEntity::getMobileNumber)
                .orElse(null);

        return new SupplierListResponseDto(
                record.getId(),
                record.getCode(),
                record.getSupplierName(),
                record.getGstNo(),
                formatAddress(record),
                record.getCity(),
                mobile
        );
    }

    private String formatAddress(SupplierEntity record) {
        return Stream.of(record.getAddressLine1(), record.getAddressLine2())
                .filter(Objects::nonNull)
                .filter(s -> !s.isBlank())
                .collect(Collectors.joining(" "));
    }
}