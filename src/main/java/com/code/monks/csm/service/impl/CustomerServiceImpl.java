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
import com.code.monks.csm.mapper.CustomerMapper;
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
    private TransportRepository transportRepo;

    @Override
    public AddCustomerResponseDto addCustomer(AddCustomerRequestDto requestDto) {
        log.info("addCustomer() called for customer: {}", requestDto.getCustomerName());

        try {
            String code = generateCode();
            if (StringUtils.isBlank(requestDto.getCustomerGroup())) {
                requestDto.setCustomerGroup(requestDto.getCustomerName());
            }
            if (StringUtils.isBlank(requestDto.getCustomerMsme())) {
                requestDto.setCustomerMsme("SMALL");
            }

            // Step 1: Validate all unique fields
            validateCustomerAndContacts(requestDto, code);

            // Step 2: Map DTO to entity
            CustomerEntity entity = new CustomerEntity();
            CustomerMapper.mapCommonFields(entity, requestDto);
            CustomerMapper.mapContacts(entity, requestDto.getContacts());
            entity.setCode(code);
            entity.setStatus(StatusEnum.ACTIVE);

            if (requestDto.getPreferredTransportIds() != null &&
                    !requestDto.getPreferredTransportIds().isEmpty()) {
                Set<TransportEntity> transports = new HashSet<>();
                for (Integer id : requestDto.getPreferredTransportIds()) {
                    transports.add(transportRepo.getReferenceById(id));
                }
                entity.setPreferredTransports(transports);
            } else {
                entity.setPreferredTransports(Collections.emptySet());
            }

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

    public PagedResponseDto<CustomerListDto> getCustomers(int page, int size) {
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

        List<CustomerListDto> dtoList = records.getContent().stream()
                .map(CustomerMapper::toListDto)
                .toList();

        return PagedResponseDto.<CustomerListDto>builder()
                .content(dtoList)
                .page(records.getNumber())
                .size(records.getSize())
                .totalElements(records.getTotalElements())
                .totalPages(records.getTotalPages())
                .last(records.isLast())
                .build();
    }

    public List<CustomerSummaryResponseDto> getAllCustomers() {
        log.info("Fetching ALL customers (no filter, non-paged)...");

        try {
            List<CustomerEntity> customers = customerRepo.findByStatus(
                    StatusEnum.ACTIVE,
                    Sort.by(Sort.Direction.DESC, "id")
            );

            log.info("Successfully fetched {} customers (including active and inactive)", customers.size());

            return customers.stream()
                    .map(c -> new CustomerSummaryResponseDto(
                            c.getId(),
                            c.getCustomerName(),
                           c.getGroupName(),
                            c.getGstNo(),
                            c.getMsme(),
                            c.getCity()
                    ))
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

            CustomerMapper.mapCommonFields(entity, request);
            CustomerMapper.mapContacts(entity, request.getContacts());

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
                    .bankName(entity.getBankName())
                    .branch(entity.getBranchName())
                    .accountName(entity.getAccountName())
                    .accountNumber(entity.getAccountNumber())
                    .ifsc(entity.getIfscCode())
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

    public PagedResponseDto<CustomerListDto> searchCustomers(String keyword, Pageable pageable){
        log.info("Searching customers with keyword: '{}' and pageable: {}", keyword, pageable);
        if (keyword == null || keyword.trim().isEmpty()) {
            log.info("Keyword is empty or null - returning empty page");
            return PagedResponseDto.<CustomerListDto>builder()
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

            List<CustomerListDto> dtoList = customersPage.getContent().stream()
                    .map(CustomerMapper::toListDto)
                    .toList();

            return PagedResponseDto.<CustomerListDto>builder()
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

    private String generateCode(){
        Integer maxId = customerRepo.findMaxCodeSuffix();
        log.info("MAX customer code suffix from DB = {}", maxId);

        int newId = (maxId != null ? maxId : 0) + 1;
        log.info("New customer numeric id generated = {}", newId);

        String code = String.format("C%06d", newId);
        log.info("Final generated customer code = {}", code);

        return code;
    }
}
