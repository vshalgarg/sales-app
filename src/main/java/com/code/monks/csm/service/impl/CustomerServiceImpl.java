package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddCustomerRequestDto;
import com.code.monks.csm.dto.request.ContactRequestDto;
import com.code.monks.csm.dto.request.DeleteCustomerRequestDto;
import com.code.monks.csm.dto.request.UpdateCustomerRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.ContactEntity;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.TransportEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.exception.CustomerException;
import com.code.monks.csm.exception.DuplicateEntryException;
import com.code.monks.csm.repository.ContactRepo;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.TransportRepository;
import com.code.monks.csm.service.CustomerService;
import com.code.monks.csm.utils.ContactUtil;
import com.code.monks.csm.utils.ValidatorUtil;
import io.micrometer.common.util.StringUtils;
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

            if (requestDto.getCustomerGroup() == null ||
                    requestDto.getCustomerGroup().trim().isEmpty()) {

                requestDto.setCustomerGroup(requestDto.getCustomerName());
            }
            if (requestDto.getCustomerMsme() == null ||
                    requestDto.getCustomerMsme().trim().isEmpty()) {

                requestDto.setCustomerMsme("SMALL");
            }

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
            throw new CustomerException(UNEXPECTED_EXCEPTION," adding customer");
        }
    }

    private void validateCustomerAndContacts(AddCustomerRequestDto requestDto, String code) {
        List<ValidatorUtil.DuplicateCheck> duplicateChecks = new ArrayList<>();

        duplicateChecks.add(new ValidatorUtil.DuplicateCheck(
                "code", () -> customerRepo.existsByCode(code)
        ));

//        if (requestDto.getContacts() != null) {
//            for (ContactRequestDto contact : requestDto.getContacts()) {
//                // Mobile number
//                String mobile = contact.getMobileNumber();
//                if (StringUtils.isNotBlank(mobile)) {
//                    duplicateChecks.add(new ValidatorUtil.DuplicateCheck(
//                            "mobile number (" + mobile + ")",
//                            () -> contactRepo.existsByMobileNumber(mobile)
//                    ));
//                }
//            }
//        }
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
                    contactEntity.setType(dto.getType());
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
        log.info("MAX customer code suffix from DB = {}", maxId);

        int newId = (maxId != null ? maxId : 0) + 1;
        log.info("New customer numeric id generated = {}", newId);

        String code = String.format("C%03d", newId);
        log.info("Final generated customer code = {}", code);

        return code;
    }

    public PagedResponseDto<GetCustomersDto> getCustomers(int page, int size) {
        log.info("Fetching active customers with pagination...");

        Page<CustomerEntity> records;
        try {
            Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "id"));
            records = customerRepo.findAllByStatus(pageable,ACTIVE);
            log.debug("Fetched {} active customer records (page {}/{})",
                    records.getNumberOfElements(), page, records.getTotalPages());
        } catch (DataAccessException dae) {
            log.error("Database error while fetching customers", dae);
            throw new CustomerException(DATA_ACCESS_ERROR, dae.getMessage());
        } catch (Exception e) {
            log.error("Unexpected error while fetching customers", e);
            throw new CustomerException(UNEXPECTED_EXCEPTION, " fetching customers");
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

    public List<GetCustomersDto> getAllCustomers() {
        log.info("Fetching ALL customers (no filter, non-paged)...");

        try {
            List<CustomerEntity> allCustomers = customerRepo.findAll(
                    Sort.by(Sort.Direction.DESC, "id")
            );

            log.info("Successfully fetched {} customers (including active and inactive)", allCustomers.size());

            return allCustomers.stream()
                    .map(this::mapToDto)
                    .collect(Collectors.toList());

        } catch (DataAccessException dae) {
            log.error("Database error while fetching all customers", dae);
            throw new CustomerException(DATA_ACCESS_ERROR, "Database error while retrieving customers");
        } catch (Exception e) {
            log.error("Unexpected error while fetching all customers", e);
            throw new CustomerException(UNEXPECTED_EXCEPTION, "Unexpected error in customer retrieval");
        }
    }

    @Override
    public void updateCustomer(Integer id, UpdateCustomerRequestDto request) {

        log.info("Update request received for Customer id={}", id);
        log.debug("Update payload: {}", request);

        try {

            CustomerEntity entity = customerRepo.findById(id)
                    .orElseThrow(() -> {
                        log.warn("Customer not found with id={}", id);
                        return new CustomerException(DATA_NOT_FOUND,
                                "Customer not found with id: " + id);
                    });

            log.debug("Existing customer found. code={}, name={}",
                    entity.getCode(), entity.getCustomerName());

            entity.setCustomerName(request.getCustomerName());
            entity.setEmail(request.getEmail());

            entity.setGroupName(
                    StringUtils.isBlank(request.getGroupName())
                            ? request.getCustomerName()
                            : request.getGroupName()
            );

            entity.setGstNo(request.getGstNo());
            entity.setReferencedBy(request.getReferencedBy());
            entity.setAddressLine1(request.getAddressLine1());
            entity.setAddressLine2(request.getAddressLine2());
            entity.setState(request.getState());
            entity.setCity(request.getCity());
            entity.setPinCode(request.getPinCode());

            entity.setMsme(
                    StringUtils.isBlank(request.getMsme())
                            ? "SMALL"
                            : request.getMsme()
            );

            entity.setRemark(request.getRemark());

            if (request.getStatus() != null) {
                entity.setStatus(request.getStatus());
            }

            if (request.getPreferredTransportIds() != null) {

                log.debug("Updating preferred transports for customer id={}", id);

                Set<TransportEntity> transports = new HashSet<>();

                for (Integer transportId : request.getPreferredTransportIds()) {
                    TransportEntity transport = transportRepo.getReferenceById(transportId);
                    transports.add(transport);
                }

                entity.getPreferredTransports().clear();
                entity.getPreferredTransports().addAll(transports);

                log.debug("Preferred transports updated. Count={}", transports.size());
            }

            if (request.getContacts() != null) {

                log.debug("Updating contacts for customer id={}, count={}",
                        id, request.getContacts().size());

                entity.getContactList().clear();

                List<ContactEntity> updatedContacts = request.getContacts()
                        .stream()
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

            customerRepo.save(entity);

            log.info("Customer updated successfully. id={}, code={}",
                    entity.getId(), entity.getCode());

        } catch (DataAccessException dae) {
            log.error("Database error while updating customer id={}", id, dae);
            throw new CustomerException(DATA_ACCESS_ERROR, "Database error while updating customer");

        } catch (Exception e) {
            log.error("Unexpected error while updating customer id={}", id, e);
            throw new CustomerException(UNEXPECTED_EXCEPTION, "Unexpected error while updating customer");
        }
    }

    @Override
    public GetCustomerByIdResponseDto getCustomerById(Integer id) {

        log.info("Fetching customer details for id={}", id);

        try {

            CustomerEntity entity = customerRepo.findById(id)
                    .orElseThrow(() -> {
                        log.warn("Customer not found with id={}", id);
                        return new CustomerException(DATA_NOT_FOUND,
                                "Customer not found with id: " + id);
                    });

            // Contacts mapping
            List<ContactRequestDto> contacts = ContactUtil.mapContacts(
                    entity.getContactList(),
                    ContactEntity::getContactPerson,
                    ContactEntity::getMobileNumber,
                    ContactEntity::getType
            );

            // Transport mapping
            List<TransportDto> transportDtos = Optional.ofNullable(entity.getPreferredTransports())
                    .orElse(Collections.emptySet())
                    .stream()
                    .map(t -> TransportDto.builder()
                            .id(t.getId())
                            .name(t.getName())
                            .build())
                    .toList();

            log.info("Customer details fetched successfully for id={}", id);

            return GetCustomerByIdResponseDto.builder()
                    .id(entity.getId())
                    .code(entity.getCode())
                    .customerName(entity.getCustomerName())
                    .email(entity.getEmail())
                    .groupName(entity.getGroupName())
                    .gstNo(entity.getGstNo())
                    .referencedBy(entity.getReferencedBy())
                    .addressLine1(entity.getAddressLine1())
                    .addressLine2(entity.getAddressLine2())
                    .state(entity.getState())
                    .city(entity.getCity())
                    .pinCode(entity.getPinCode())
                    .msme(entity.getMsme())
                    .remark(entity.getRemark())
                    .status(entity.getStatus())
                    .contacts(contacts)
                    .preferredTransports(transportDtos)
                    .build();

        } catch (DataAccessException dae) {
            log.error("Database error while fetching customer id={}", id, dae);
            throw new CustomerException(DATA_ACCESS_ERROR,
                    "Database error while fetching customer");

        } catch (Exception e) {
            log.error("Unexpected error while fetching customer id={}", id, e);
            throw new CustomerException(UNEXPECTED_EXCEPTION,
                    "Unexpected error while fetching customer");
        }
    }


    private GetCustomersDto mapToDto(CustomerEntity record) {
        log.debug("Mapping CustomerEntity with code={} to DTO", record.getCode());

        List<ContactRequestDto> contacts = ContactUtil.mapContacts(
                record.getContactList(),
                ContactEntity::getContactPerson,
                ContactEntity::getMobileNumber,
                ContactEntity::getType
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
                .id(record.getId())
                .code(record.getCode())
                .customerName(record.getCustomerName())
                .email(record.getEmail())
                .customerGroup(record.getGroupName())
                .customerGstNo(record.getGstNo())
                .customerMsme(record.getMsme())
                .referencedBy(record.getReferencedBy())
                .address(ContactUtil.formatAddress(record.getAddressLine1(), record.getAddressLine2()))
                .state(record.getState())
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
            throw new CustomerException(UNEXPECTED_EXCEPTION, "deleting customer");
        }
    }

    public PagedResponseDto<SearchCustomersResponseDto> searchCustomers(String keyword, Pageable pageable){
        log.info("Searching customers with keyword: '{}' and pageable: {}", keyword, pageable);
        if (keyword == null || keyword.trim().isEmpty()) {
            log.info("Keyword is empty or null - returning empty page");
            return PagedResponseDto.<SearchCustomersResponseDto>builder()
                    .content(List.of())
                    .page(pageable.getPageNumber() + 1)
                    .size(pageable.getPageSize())
                    .totalElements(0L)
                    .totalPages(0)
                    .last(true)
                    .build();
        }

        String trimmedKeyword = keyword.trim();
        log.debug("Executing search with trimmed keyword: '{}'", trimmedKeyword);

        try {
            Page<CustomerEntity> customersPage = customerRepo.searchByKeyword(trimmedKeyword, pageable);

            List<SearchCustomersResponseDto> dtoList = customersPage.getContent().stream()
                    .map(customer -> mapToDto(customer, this::mapSupplierToSearchSuppliersDto))
                    .toList();

            return PagedResponseDto.<SearchCustomersResponseDto>builder()
                    .content(dtoList)
                    .page(customersPage.getNumber() + 1)     // 1-based page number for UI
                    .size(customersPage.getSize())
                    .totalElements(customersPage.getTotalElements())
                    .totalPages(customersPage.getTotalPages())
                    .last(customersPage.isLast())
                    .build();
        }
        catch (Exception e) {
                log.error("Unexpected error during customer search for keyword: '{}'", trimmedKeyword, e);
                throw new CustomerException(UNEXPECTED_EXCEPTION, "Unexpected error in customer search");
            }
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
                ContactEntity::getType
        );

        List<TransportDto> transportDtos = Optional.ofNullable(record.getPreferredTransports())
                .orElse(Collections.emptySet())
                .stream()
                .map(transport -> TransportDto.builder()
                        .id(transport.getId())
                        .name(transport.getName())
                        .build())
                .sorted(Comparator.comparing(TransportDto::getName))
                .toList();
        return SearchCustomersResponseDto.builder()
                .id(record.getId())
                .code(record.getCode())
                .customerName(record.getCustomerName())
                .customerGroup(record.getGroupName())
                .customerGstNo((record.getGstNo()))
                .referencedBy(record.getReferencedBy())
                .address(ContactUtil.formatAddress(record.getAddressLine1(), record.getAddressLine2()))
                .state(record.getState())
                .city(record.getCity())
                .pinCode(record.getPinCode())
                .customerMsme(record.getMsme())
                .contacts(contacts)
                .preferredTransports(transportDtos)
                .remark(record.getRemark())
                .build();
    }
}
