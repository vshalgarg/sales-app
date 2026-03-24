package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.request.AddCustomerRequestDto;
import com.code.monks.csm.dto.request.ContactRequestDto;
import com.code.monks.csm.dto.request.UpdateCustomerRequestDto;
import com.code.monks.csm.dto.response.CustomerListDto;
import com.code.monks.csm.entity.ContactEntity;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.utils.ContactUtil;
import org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.List;

public class CustomerMapper {

    public static void mapCommonFields(CustomerEntity entity, AddCustomerRequestDto dto) {
        entity.setCustomerName(dto.getCustomerName());
        entity.setEmail(dto.getEmail());
        entity.setGroupName(dto.getCustomerGroup());
        entity.setGstNo(dto.getCustomerGstNo());
        entity.setReferencedBy(dto.getReferencedBy());
        entity.setAddressLine1(dto.getAddressLine1());
        entity.setAddressLine2(dto.getAddressLine2());
        entity.setState(dto.getState());
        entity.setCity(dto.getCity());
        entity.setPinCode(dto.getPinCode());
        entity.setMsme(dto.getCustomerMsme());
        entity.setRemark(dto.getRemark());

        entity.setBankName(dto.getBankName());
        entity.setIfscCode(dto.getIfsc());
        entity.setBranchName(dto.getBranch());
        entity.setAccountName(dto.getAccountName());
        entity.setAccountNumber(dto.getAccountNumber());
    }

    public static void mapCommonFields(CustomerEntity entity, UpdateCustomerRequestDto dto) {
        entity.setCustomerName(dto.getCustomerName());
        entity.setEmail(dto.getEmail());

        entity.setGroupName(
                StringUtils.isBlank(dto.getGroupName())
                        ? dto.getCustomerName()
                        : dto.getGroupName()
        );

        entity.setGstNo(dto.getGstNo());
        entity.setReferencedBy(dto.getReferencedBy());
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

        entity.setBankName(StringUtils.trimToNull(dto.getBankName()));
        entity.setIfscCode(StringUtils.trimToNull(dto.getIfsc()));
        entity.setBranchName(StringUtils.trimToNull(dto.getBranch()));
        entity.setAccountName(StringUtils.trimToNull(dto.getAccountName()));
        entity.setAccountNumber(StringUtils.trimToNull(dto.getAccountNumber()));
    }

    public static void mapContactsForCreate(CustomerEntity entity, List<ContactRequestDto> contacts) {

        if (contacts == null) return;

        List<ContactEntity> contactList = contacts.stream()
                .map(dto -> {
                    ContactEntity contact = new ContactEntity();
                    contact.setContactPerson(dto.getContactPerson());
                    contact.setMobileNumber(dto.getMobileNumber());
                    contact.setType(dto.getType());
                    contact.setCustomer(entity);
                    return contact;
                })
                .toList();

        entity.setContactList(contactList);
    }

    public static void mapContactsForUpdate(CustomerEntity entity, List<ContactRequestDto> contacts) {

        if (contacts == null) return;

        if (entity.getContactList() == null) {
            entity.setContactList(new ArrayList<>());
        } else {
            entity.getContactList().clear();
        }

        List<ContactEntity> updatedContacts = contacts.stream()
                .map(dto -> {
                    ContactEntity contact = new ContactEntity();
                    contact.setContactPerson(dto.getContactPerson());
                    contact.setMobileNumber(dto.getMobileNumber());
                    contact.setType(dto.getType());
                    contact.setCustomer(entity);
                    return contact;
                })
                .toList();

        entity.getContactList().addAll(updatedContacts);
    }

    public static CustomerListDto toListDto(CustomerEntity entity) {

        List<ContactRequestDto> contacts = ContactUtil.mapContacts(
                entity.getContactList(),
                ContactEntity::getContactPerson,
                ContactEntity::getMobileNumber,
                ContactEntity::getType
        );

        return CustomerListDto.builder()
                .id(entity.getId())
                .code(entity.getCode())
                .customerName(entity.getCustomerName())
                .customerGstNo(entity.getGstNo())
                .address(ContactUtil.formatAddress(entity.getAddressLine1(), entity.getAddressLine2()))
                .city(entity.getCity())
                .contacts(contacts)
                .build();
    }

}
