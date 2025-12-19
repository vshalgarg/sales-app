package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddCustomerRequestDto;
import com.code.monks.csm.dto.request.ContactRequestDto;
import com.code.monks.csm.dto.request.DeleteCustomerRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.ContactEntity;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.entity.TransportEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.exception.CustomerException;
import com.code.monks.csm.exception.DuplicateEntryException;
import com.code.monks.csm.exception.SupplierException;
import com.code.monks.csm.repository.ContactRepo;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.TransportRepository;
import com.code.monks.csm.service.CustomerService;
import com.code.monks.csm.utils.ContactUtil;
import com.code.monks.csm.utils.ValidatorUtil;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.function.Function;
import java.util.stream.Collectors;

import static com.code.monks.csm.enums.ResponseErrorCode.*;
import static com.code.monks.csm.enums.StatusEnum.ACTIVE;
import static com.code.monks.csm.enums.StatusEnum.INACTIVE;

@Service
@AllArgsConstructor
@Slf4j
public class CustomerServiceImpl implements CustomerService {

    private final CustomerRepo customerRepo;

    private final ValidatorUtil validatorUtil;

    private final ContactRepo contactRepo;
    private TransportRepository transportRepo;

    @Override
    public AddCustomerResponseDto addCustomer(AddCustomerRequestDto requestDto) {
        log.info("addCustomer() called for customer: {}", requestDto.getCustomerName());

        try {
            String code = generateCode();

            // Step 1: Validate all unique fields
            validateCustomerAndContacts(requestDto, code);

            // Step 2: Map DTO to entity
            CustomerEntity entity = mapToCustomerEntity(requestDto, code);

            // Step 3: Save customer
            customerRepo.save(entity);
            log.info("Customer '{}' saved successfully with {} contacts",
                    entity.getCustomerName(),
                    entity.getContactList().size());

            return AddCustomerResponseDto.builder()
                    .message("Customer added successfully")
                    .build();

        } catch (DuplicateEntryException ex) {
            log.warn("Bill validation failed for {}",ex.getMessage());
            throw ex;
        }catch (Exception e) {
            log.error("Error while adding customer '{}'", requestDto.getCustomerName(), e);
            throw new CustomerException(UNEXPECTED_EXCEPTION,e.getMessage());
        }
    }

    private void validateCustomerAndContacts(AddCustomerRequestDto requestDto, String code) {
        List<ValidatorUtil.DuplicateCheck> duplicateChecks = new ArrayList<>();

        // Customer-level checks
        duplicateChecks.add(new ValidatorUtil.DuplicateCheck(
                "GST number", () -> customerRepo.existsByGstNo(requestDto.getCustomerGstNo())
        ));
        duplicateChecks.add(new ValidatorUtil.DuplicateCheck(
                "code", () -> customerRepo.existsByCode(code)
        ));

        // Contact-level checks
        if (requestDto.getContacts() != null) {
            for (ContactRequestDto contact : requestDto.getContacts()) {
                duplicateChecks.add(new ValidatorUtil.DuplicateCheck(
                        "mobile number (" + contact.getMobileNumber() + ")",
                        () -> contactRepo.existsByMobileNumber(contact.getMobileNumber())
                ));
                duplicateChecks.add(new ValidatorUtil.DuplicateCheck(
                        "phone (" + contact.getPhone() + ")",
                        () -> contactRepo.existsByPhone(contact.getPhone())
                ));
            }
        }

        validatorUtil.validateUniqueFields(duplicateChecks);
    }

    private CustomerEntity mapToCustomerEntity(AddCustomerRequestDto requestDto, String code) {
        CustomerEntity entity = AddCustomerResponseDto.dtoToEntity(requestDto);
        entity.setCode(code);
        entity.setStatus(StatusEnum.ACTIVE);

        List<ContactEntity> contactList = requestDto.getContacts().stream()
                .map(dto -> {
                    ContactEntity contactEntity = new ContactEntity();
                    contactEntity.setContactPerson(dto.getContactPerson());
                    contactEntity.setMobileNumber(dto.getMobileNumber());
                    contactEntity.setPhone(dto.getPhone());
                    contactEntity.setCustomer(entity); // Owning side
                    return contactEntity;
                })
                .toList();

        entity.setContactList(contactList);

        if (requestDto.getPreferredTransportIds() != null && !requestDto.getPreferredTransportIds().isEmpty()) {
            Set<TransportEntity> transports = new HashSet<>();

            for (Integer id : requestDto.getPreferredTransportIds()) {
                TransportEntity transport = transportRepo.getReferenceById(id);
                transports.add(transport);
            }
            entity.setPreferredTransports(transports);
        } else {
            entity.setPreferredTransports(Collections.emptySet());
        }

        return entity;
    }

    private String generateCode(){
        Integer maxId = customerRepo.findMaxCodeSuffix();
        int newId = (maxId != null ? maxId : 0) + 1;
        return String.format("C%03d",newId);
    }

    public PagedResponseDto<GetCustomersDto> getCustomers(int page, int size) {
        log.info("Fetching active customers with pagination...");

        Page<CustomerEntity> records;
        try {
            Pageable pageable = PageRequest.of(page-1, size, Sort.by(Sort.Direction.DESC, "id"));
            records = customerRepo.findAllByStatus(pageable,ACTIVE);
            log.debug("Fetched {} active customer records (page {}/{})",
                    records.getNumberOfElements(), page, records.getTotalPages());
        } catch (DataAccessException dae) {
            log.error("Database error while fetching customers", dae);
            throw new CustomerException(DATA_ACCESS_ERROR, dae.getMessage());
        } catch (Exception e) {
            log.error("Unexpected error while fetching customers", e);
            throw new CustomerException(UNEXPECTED_EXCEPTION, e.getMessage());
        }

        List<GetCustomersDto> dtoList = records.getContent()
                .stream()
                .map(this::mapToDto)
                .collect(Collectors.toList());

        return PagedResponseDto.<GetCustomersDto>builder()
                .content(dtoList)
                .page(records.getNumber())
                .size(records.getSize())
                .totalElements(records.getTotalElements())
                .totalPages(records.getTotalPages())
                .last(records.isLast())
                .build();
    }

    private GetCustomersDto mapToDto(CustomerEntity record) {
        log.debug("Mapping CustomerEntity with code={} to DTO", record.getCode());

        List<ContactRequestDto> contacts = ContactUtil.mapContacts(
                record.getContactList(),
                ContactEntity::getContactPerson,
                ContactEntity::getMobileNumber,
                ContactEntity::getPhone
        );

        List<TransportDto> transportDtos = Optional.ofNullable(record.getPreferredTransports())
                .orElse(Collections.emptySet())
                .stream()
                .map(transport -> TransportDto.builder()
                        .id(transport.getId())
                        .name(transport.getName())
                        .build())
                .sorted(Comparator.comparing(TransportDto::getName)) // optional: alphabetical order
                .toList();

        return GetCustomersDto.builder()
                .code(record.getCode())
                .customerName(record.getCustomerName())
                .customerGroup(record.getGroupName())
                .customerGstNo(record.getGstNo())
                .customerMsme(record.getMsme())
                .referencedBy(record.getReferencedBy())
                .address(ContactUtil.formatAddress(record.getAddressLine1(), record.getAddressLine2()))
                .city(record.getCity())
                .pinCode(record.getPinCode())
                .contacts(contacts)
                .preferredTransports(transportDtos)
                .remark(record.getRemark())
                .build();
    }

    public DeleteCustomerResponseDto deleteCustomer(DeleteCustomerRequestDto requestDto) {
        String code = requestDto.getCustomerCode();
        log.info("Request received to delete customer with code={}", code);

        try {
            CustomerEntity entity = customerRepo.findOneByCode(code)
                    .orElseThrow(() -> {
                        log.warn("No customer found with code={}", code);
                        return new CustomerException(DATA_NOT_FOUND,"For customer with code: "+code);
                    });

            log.debug("Customer with code={} found. Setting status to INACTIVE", code);
            entity.setStatus(INACTIVE);
            customerRepo.save(entity);
            log.info("Customer with code={} successfully marked as INACTIVE", code);

            return DeleteCustomerResponseDto.builder()
                    .message("Customer with code: " + code + " successfully deleted")
                    .build();

        } catch (DataAccessException dae) {
            log.error("Database error while deleting customer with code={}", code, dae);
            throw new CustomerException(DATA_ACCESS_ERROR, dae.getMessage());
        } catch (Exception e) {
            log.error("Unexpected error occurred while deleting customer with code={}", code, e);
            throw new CustomerException(UNEXPECTED_EXCEPTION, e.getMessage());
        }
    }

    public List<SearchCustomersResponseDto> searchCustomers(String keyword){
        if (keyword == null || keyword.trim().isEmpty()) {
            return List.of();
        }

        List<CustomerEntity> customers = customerRepo.searchByKeyword(keyword.trim());
        return customers.stream()
                .map(s -> mapToDto(s, this::mapSupplierToSearchSuppliersDto))
                .toList();
    }

    private <R> R mapToDto(CustomerEntity record, Function<CustomerEntity, R> mapper) {
        log.debug("Mapping CustomerEntity with code:{} to DTO", record.getCode());
        return mapper.apply(record);
    }

    private SearchCustomersResponseDto mapSupplierToSearchSuppliersDto(CustomerEntity record) {
        List<ContactRequestDto> contacts = ContactUtil.mapContacts(
                record.getContactList(),
                ContactEntity::getContactPerson,
                ContactEntity::getMobileNumber,
                ContactEntity::getPhone
        );

        String preferredTransports = Optional.ofNullable(record.getPreferredTransports())
                .orElse(Collections.emptySet())
                .stream()
                .map(TransportEntity::getName)
                .filter(Objects::nonNull)
                .sorted()  // optional: alphabetical order
                .collect(Collectors.joining(", "));

        if (preferredTransports.isEmpty()) {
            preferredTransports = null;
        }
        return SearchCustomersResponseDto.builder()
                .id(record.getId())
                .code(record.getCode())
                .customerName(record.getCustomerName())
                .customerGroup(record.getGroupName())
                .customerGstNo((record.getGstNo()))
                .referencedBy(record.getReferencedBy())
                .address(ContactUtil.formatAddress(record.getAddressLine1(), record.getAddressLine2()))
                .city(record.getCity())
                .pinCode(record.getPinCode())
                .customerMsme(record.getMsme())
                .contacts(contacts)
                .preferredTransports(preferredTransports)
                .remark(record.getRemark())
                .build();
    }
}
