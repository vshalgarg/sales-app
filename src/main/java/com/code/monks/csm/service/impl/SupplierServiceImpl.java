package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddSupplierRequestDto;
import com.code.monks.csm.dto.request.ContactRequestDto;
import com.code.monks.csm.dto.request.DeleteSupplierRequestDto;
import com.code.monks.csm.dto.request.UpdateSupplierRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.ContactEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.entity.TransportEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.exception.CustomerException;
import com.code.monks.csm.exception.DuplicateEntryException;
import com.code.monks.csm.exception.SupplierException;
import com.code.monks.csm.repository.ContactRepo;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.repository.TransportRepository;
import com.code.monks.csm.service.SupplierService;
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
public class SupplierServiceImpl implements SupplierService {

    private final SupplierRepo supplierRepo;

    private final ContactRepo contactRepo;

    private final ValidatorUtil validatorUtil;
    private TransportRepository transportRepo;

    public AddSupplierResponseDto addSupplier(AddSupplierRequestDto requestDto) {
        log.info("addSupplier() called for supplier: {}", requestDto.getSupplierName());

        try {
            String code = generateCode();
            if (requestDto.getSupplierGroup() == null ||
                    requestDto.getSupplierGroup().trim().isEmpty()) {

                requestDto.setSupplierGroup(requestDto.getSupplierName());
            }
            if (requestDto.getSupplierMsme() == null ||
                    requestDto.getSupplierMsme().trim().isEmpty()) {

                requestDto.setSupplierMsme("SMALL");
            }
            validateSupplierAndContacts(requestDto, code);
            SupplierEntity entity = mapToSupplierEntity(requestDto, code);

            supplierRepo.save(entity);
            log.info("Supplier '{}' saved successfully with {} contacts",
                    entity.getSupplierName(),
                    entity.getContactList().size());
            return AddSupplierResponseDto.builder()
                    .message("Supplier added successfully")
                    .build();

        } catch (DuplicateEntryException ex) {
            log.warn("Supplier validation failed for {}", ex.getMessage());
            throw ex;
        }catch (Exception e) {
            log.error("Error while adding supplier '{}'", requestDto.getSupplierName(), e);
            throw new CustomerException(UNEXPECTED_EXCEPTION,e.getMessage());
        }
    }

    private void validateSupplierAndContacts(AddSupplierRequestDto requestDto, String code) {
        List<ValidatorUtil.DuplicateCheck> duplicateChecks = new ArrayList<>();

        duplicateChecks.add(new ValidatorUtil.DuplicateCheck(
                "code", () -> supplierRepo.existsByCode(code)
        ));

//        if (requestDto.getContacts() != null) {
//            for (ContactRequestDto contact : requestDto.getContacts()) {
//                duplicateChecks.add(new ValidatorUtil.DuplicateCheck(
//                        "mobile number (" + contact.getMobileNumber() + ")",
//                        () -> contactRepo.existsByMobileNumber(contact.getMobileNumber())
//                ));
//            }
//        }

        validatorUtil.validateUniqueFields(duplicateChecks);
    }

    private SupplierEntity mapToSupplierEntity(AddSupplierRequestDto requestDto, String code) {
        SupplierEntity entity = AddSupplierResponseDto.dtoToEntity(requestDto);
        entity.setCode(code);
        entity.setStatus(StatusEnum.ACTIVE);

        List<ContactEntity> contactList = requestDto.getContacts().stream()
                .map(dto -> {
                    ContactEntity contactEntity = new ContactEntity();
                    contactEntity.setContactPerson(dto.getContactPerson());
                    contactEntity.setMobileNumber(dto.getMobileNumber());
                    contactEntity.setType(dto.getType());
                    contactEntity.setSupplier(entity); // owning side
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
        Integer maxId = supplierRepo.findMaxCodeSuffix();
        int newId = (maxId != null ? maxId : 0) + 1;
        return String.format("S%03d",newId);
    }

    public PagedResponseDto<GetSuppliersDto> getSuppliers(int page, int size) {
        log.info("Fetching active suppliers...");

        Page<SupplierEntity> records;
        try {
            // ✅ Add sorting by latest (descending order of ID)
            Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "id"));

            // ✅ Fetch only active suppliers with sorting
            records = supplierRepo.findAllByStatus(
                    StatusEnum.ACTIVE, pageable
            );

            log.debug("Fetched {} active supplier records (page {}/{})",
                    records.getNumberOfElements(), page, records.getTotalPages());
        } catch (DataAccessException dae) {
            log.error("Database error while fetching suppliers", dae);
            throw new SupplierException(DATA_ACCESS_ERROR, "while fetching suppliers");
        } catch (Exception e) {
            log.error("Unexpected error while fetching suppliers", e);
            throw new SupplierException(UNEXPECTED_EXCEPTION, "while fetching suppliers");
        }

        // ✅ Map entities to DTOs
        List<GetSuppliersDto> dtoList = records.getContent()
                .stream()
                .map(this::mapSupplierToGetSuppliersDto)
                .collect(Collectors.toList());

        // ✅ Build and return paged response
        return PagedResponseDto.<GetSuppliersDto>builder()
                .content(dtoList)
                .page(records.getNumber() + 1) // (optional: +1 to make it user-friendly)
                .size(records.getSize())
                .totalElements(records.getTotalElements())
                .totalPages(records.getTotalPages())
                .last(records.isLast())
                .build();
    }

    private GetSuppliersDto mapSupplierToGetSuppliersDto(SupplierEntity record) {
        List<ContactRequestDto> contacts = ContactUtil.mapContacts(
                record.getContactList(),
                ContactEntity::getContactPerson,
                ContactEntity::getMobileNumber,
                ContactEntity::getType
        );

        List<TransportDto> transportDtos = Optional.ofNullable(record.getPreferredTransports())
                .orElse(Collections.emptySet())
                .stream()
                .map(t -> TransportDto.builder()
                        .id(t.getId())
                        .name(t.getName())
                        .build())
                .sorted(Comparator.comparing(TransportDto::getName))
                .toList();

        return GetSuppliersDto.builder()
                .id(record.getId())
                .code(record.getCode())
                .supplierName(record.getSupplierName())
                .supplierGroup(record.getGroupName())
                .supplierGstNo(record.getGstNo())
                .email(record.getEmail())
                .referenceBy(record.getReferenceBy())
                .commissionScheme(record.getCommissionScheme())
                .commissionRate(record.getCommissionRate())
                .address(ContactUtil.formatAddress(record.getAddressLine1(), record.getAddressLine2()))
                .state(record.getState())
                .city(record.getCity())
                .pinCode(record.getPinCode())
                .contacts(contacts)
                .supplierMsme(record.getMsme())
                .preferredTransports(transportDtos)
                //.preferredTransport(record.getPreferredTransport())
                .remark(record.getRemark())
                .build();
    }

    private <R> R mapToDto(SupplierEntity record, Function<SupplierEntity, R> mapper) {
        log.debug("Mapping SupplierEntity with code={} to DTO", record.getCode());
        return mapper.apply(record);
    }


    public DeleteSupplierResponseDto deleteSupplier(DeleteSupplierRequestDto requestDto) {
        String code = requestDto.getCode();
        log.info("deleteSupplier() called for supplier code={}", code);

        try {
            SupplierEntity entity = supplierRepo.findOneByCode(code).orElseThrow(()-> {
                    log.warn("No supplier found with code={}", code);
                    return new SupplierException(DATA_NOT_FOUND,"For supplier with code: "+code);
            });

            log.debug("Supplier with code={} found. Marking as INACTIVE", code);
            entity.setStatus(INACTIVE);
            supplierRepo.save(entity);

            log.info("Supplier with code={} successfully marked as INACTIVE", code);
            return DeleteSupplierResponseDto.builder()
                    .message("Supplier with code: " + code + " successfully deleted")
                    .build();

        } catch (DataAccessException dae) {
            log.error("Database error while deleting supplier with code={}", code, dae);
            return DeleteSupplierResponseDto.builder()
                    .message("Database error occurred while deleting supplier: " + code)
                    .build();
        } catch (Exception e) {
            log.error("Unexpected error while deleting supplier with code={}", code, e);
            return DeleteSupplierResponseDto.builder()
                    .message("Unexpected error occurred while deleting supplier: " + code)
                    .build();
        }
    }

    public Page<SearchSuppliersResponseDto> searchSuppliers(String keyword, Pageable pageable) {

        log.info("Search suppliers called with keyword: '{}' and pageable: {}",
                keyword, pageable);

        if (keyword == null || keyword.trim().isEmpty()) {
            log.info("Search keyword is null or empty - returning empty page");
            return Page.empty(pageable);
        }

        String trimmedKeyword = keyword.trim();
        log.debug("Searching suppliers with trimmed keyword: '{}'", trimmedKeyword);

        try {
            Page<SupplierEntity> suppliersPage = supplierRepo.searchByKeyword(trimmedKeyword, pageable);
            log.info("Search completed successfully - found {} suppliers (page {}/{}, total elements: {})",
                    suppliersPage.getNumberOfElements(),
                    suppliersPage.getNumber() + 1,
                    suppliersPage.getTotalPages(),
                    suppliersPage.getTotalElements());

            return suppliersPage.map(s -> mapToDto(s, this::mapSupplierToSearchSuppliersDto));
        }
        catch (Exception e) {
                log.error("Unexpected error while searching suppliers with keyword: '{}'", trimmedKeyword, e);
                throw new SupplierException(UNEXPECTED_EXCEPTION, "Unexpected error during supplier search");
            }
    }

    @Override
    public List<GetSuppliersDto> getAllSuppliers() {

        log.info("Fetching all active suppliers (non-paged)...");
        try {
       List<SupplierEntity> supplierEntityList =  supplierRepo.findAll();
        return supplierEntityList.stream()
                .map(this::mapSupplierToGetSuppliersDto)
                .collect(Collectors.toList());

        } catch (DataAccessException dae) {
            log.error("Database error while fetching all suppliers", dae);
            throw new SupplierException(DATA_ACCESS_ERROR, dae.getMessage());
        } catch (Exception e) {
            log.error("Unexpected error while fetching all suppliers", e);
            throw new SupplierException(UNEXPECTED_EXCEPTION, e.getMessage());
        }
    }

    @Override
    public void updateSupplier(Integer id, UpdateSupplierRequestDto request) {

        log.info("Update request received for Supplier id={}", id);
        log.debug("Update payload for supplier id={} : {}", id, request);

        try {

            SupplierEntity entity = supplierRepo.findById(id)
                    .orElseThrow(() -> {
                        log.warn("Supplier not found for update. id={}", id);
                        return new SupplierException(DATA_NOT_FOUND,
                                "Supplier not found with id: " + id);
                    });

            entity.setSupplierName(request.getSupplierName());
            entity.setEmail(request.getEmail());
            entity.setGroupName(
                    StringUtils.isBlank(request.getGroupName())
                            ? request.getSupplierName()
                            : request.getGroupName()
            );
            entity.setGstNo(request.getGstNo());
            entity.setCommissionScheme(request.getCommissionScheme());
            entity.setCommissionRate(request.getCommissionRate());
            entity.setReferenceBy(request.getReferenceBy());
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
                log.debug("Updating supplier status to {}", request.getStatus());
                entity.setStatus(request.getStatus());
            }

            if (request.getPreferredTransportIds() != null) {

                log.debug("Updating preferred transports for supplier id={}", id);

                Set<TransportEntity> transports = new HashSet<>();

                for (Integer transportId : request.getPreferredTransportIds()) {
                    log.trace("Fetching transport id={}", transportId);
                    TransportEntity transport = transportRepo.getReferenceById(transportId);
                    transports.add(transport);
                }

                entity.getPreferredTransports().clear();
                entity.getPreferredTransports().addAll(transports);

                log.debug("Preferred transports updated. Count={}", transports.size());
            }

            if (request.getContacts() != null) {

                log.debug("Updating contacts for supplier id={}. New count={}",
                        id, request.getContacts().size());

                entity.getContactList().clear();

                List<ContactEntity> updatedContacts = request.getContacts()
                        .stream()
                        .map(dto -> {
                            ContactEntity contact = new ContactEntity();
                            contact.setContactPerson(dto.getContactPerson());
                            contact.setMobileNumber(dto.getMobileNumber());
                            contact.setType(dto.getType());
                            contact.setSupplier(entity);
                            return contact;
                        })
                        .toList();

                entity.getContactList().addAll(updatedContacts);
            }

            supplierRepo.save(entity);

            log.info("Supplier updated successfully. id={}, code={}",
                    entity.getId(), entity.getCode());

        } catch (DuplicateEntryException ex) {
            log.error("Duplicate entry while updating supplier id={}", id, ex);
            throw ex;

        } catch (DataAccessException dae) {
            log.error("Database error while updating supplier id={}", id, dae);
            throw new SupplierException(DATA_ACCESS_ERROR,
                    "Database error while updating supplier");

        } catch (Exception e) {
            log.error("Unexpected error while updating supplier id={}", id, e);
            throw new SupplierException(UNEXPECTED_EXCEPTION,
                    "Unexpected error while updating supplier");
        }
    }

    @Override
    public GetSupplierByIdResponseDto getSupplierById(Integer id) {

        log.info("Fetching supplier details for id={}", id);

        try {

            SupplierEntity entity = supplierRepo.findById(id)
                    .orElseThrow(() -> {
                        log.warn("Supplier not found with id={}", id);
                        return new SupplierException(DATA_NOT_FOUND,
                                "Supplier not found with id: " + id);
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

            log.info("Supplier details fetched successfully for id={}", id);

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
                    .remark(entity.getRemark())
                    .status(entity.getStatus())
                    .contacts(contacts)
                    .preferredTransports(transportDtos)
                    .build();

        } catch (DataAccessException dae) {
            log.error("Database error while fetching supplier id={}", id, dae);
            throw new SupplierException(DATA_ACCESS_ERROR,
                    "Database error while fetching supplier");

        } catch (Exception e) {
            log.error("Unexpected error while fetching supplier id={}", id, e);
            throw new SupplierException(UNEXPECTED_EXCEPTION,
                    "Unexpected error while fetching supplier");
        }
    }

    public List<SearchSuppliersResponseDto> searchSuppliers(String keyword) {

        log.info("Search suppliers called with keyword: '{}' ",
                keyword);

        if (keyword == null || keyword.trim().isEmpty()) {
            return List.of();
        }

        List<SupplierEntity> suppliers = supplierRepo.searchByKeyword(keyword.trim());
        log.info("Search completed successfully");

        return suppliers.stream()
                .map(s -> mapToDto(s, this::mapSupplierToSearchSuppliersDto))
                .toList();
    }

    private SearchSuppliersResponseDto mapSupplierToSearchSuppliersDto(SupplierEntity record) {
        List<ContactRequestDto> contacts = ContactUtil.mapContacts(
                record.getContactList(),
                ContactEntity::getContactPerson,
                ContactEntity::getMobileNumber,
                ContactEntity::getType
        );

        List<TransportDto> transportDtos = Optional.ofNullable(record.getPreferredTransports())
                .orElse(Collections.emptySet())
                .stream()
                .map(t -> TransportDto.builder()
                        .id(t.getId())
                        .name(t.getName())
                        .build())
                .sorted(Comparator.comparing(TransportDto::getName))
                .toList();

        return SearchSuppliersResponseDto.builder()
                .id(record.getId())
                .code(record.getCode())
                .supplierName(record.getSupplierName())
                .supplierGroup(record.getGroupName())
                .supplierGstNo(record.getGstNo())
                .commissionScheme(record.getCommissionScheme())
                .commissionRate(record.getCommissionRate())
                .address(ContactUtil.formatAddress(record.getAddressLine1(), record.getAddressLine2()))
                .state(record.getState())
                .city(record.getCity())
                .pinCode(record.getPinCode())
                .contacts(contacts)
                .supplierMsme(record.getMsme())
                .preferredTransports(transportDtos)
                .remark(record.getRemark())
                .build();
    }
}
