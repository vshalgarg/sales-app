package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.request.AddCustomerRequestDto;
import com.code.monks.csm.dto.request.BankDetailRequestDto;
import com.code.monks.csm.dto.request.ContactRequestDto;
import com.code.monks.csm.dto.request.UpdateCustomerRequestDto;
import com.code.monks.csm.dto.response.CustomerListDto;
import com.code.monks.csm.entity.BankDetailEntity;
import com.code.monks.csm.entity.ContactEntity;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.enums.ResponseErrorCode;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.utils.ContactUtil;
import org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

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

        if (dto.getBankDetails() != null) {
            List<BankDetailEntity> bankDetails = dto.getBankDetails()
                    .stream()
                    .map(bankDto -> {
                        BankDetailEntity bank = new BankDetailEntity();
                        bank.setBankName(bankDto.getBankName());
                        bank.setIfscCode(bankDto.getIfscCode());
                        bank.setBranchName(bankDto.getBranchName());
                        bank.setAccountName(bankDto.getAccountName());
                        bank.setAccountNumber(bankDto.getAccountNumber());
                        bank.setCustomer(entity);
                        return bank;
                    })
                    .toList();
            entity.setBankDetails(bankDetails);
        }
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

        if (dto.getBankDetails() != null) {
            List<BankDetailEntity> existingBanks = entity.getBankDetails();
            Map<Integer, BankDetailEntity> existingBankMap = existingBanks
                            .stream()
                            .filter(bank -> bank.getId() != null)
                            .collect(Collectors.toMap(
                                    BankDetailEntity::getId,
                                    Function.identity()
                            ));

            for (BankDetailRequestDto bankDto : dto.getBankDetails()) {
                BankDetailEntity bank;
                if (bankDto.getId() != null) {
                    bank = existingBankMap.get(bankDto.getId());
                    if (bank == null) {
                        throw new ResourceNotFoundException(ResponseErrorCode.DATA_NOT_FOUND,"Bank detail not found with id: " + bankDto.getId());
                    }

                } else {
                    bank = new BankDetailEntity();
                    bank.setCustomer(entity);
                    existingBanks.add(bank);
                }

                bank.setBankName(bankDto.getBankName());
                bank.setIfscCode(bankDto.getIfscCode());
                bank.setBranchName(bankDto.getBranchName());
                bank.setAccountName(bankDto.getAccountName());
                bank.setAccountNumber(bankDto.getAccountNumber());
            }
        }
    }

    public static void mapContacts(CustomerEntity entity, List<ContactRequestDto> contacts) {

        if (contacts == null) return;

        if (entity.getContactList() == null) {
            entity.setContactList(new ArrayList<>());
        } else {
            entity.getContactList().clear();
        }

        contacts.forEach(dto -> {
            ContactEntity contact = new ContactEntity();
            contact.setContactPerson(dto.getContactPerson());
            contact.setMobileNumber(dto.getMobileNumber());
            contact.setType(dto.getType());
            contact.setCustomer(entity);

            entity.getContactList().add(contact);
        });
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
