package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddSupplierRequestDto;
import com.code.monks.csm.dto.request.DeleteSupplierRequestDto;
import com.code.monks.csm.dto.request.UpdateSupplierRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.entity.TransportEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.exception.CustomerException;
import com.code.monks.csm.exception.DuplicateEntryException;
import com.code.monks.csm.exception.SupplierException;
import com.code.monks.csm.mapper.SupplierMapper;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.repository.TransportRepository;
import com.code.monks.csm.service.SupplierService;
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

import static com.code.monks.csm.enums.ResponseErrorCode.*;
import static com.code.monks.csm.enums.StatusEnum.INACTIVE;

@Service
@AllArgsConstructor
@Slf4j
public class SupplierServiceImpl implements SupplierService {

    private final SupplierRepo supplierRepo;
    private final SupplierMapper supplierMapper;
    private final ValidatorUtil validatorUtil;
    private TransportRepository transportRepo;

    public AddSupplierResponseDto addSupplier(AddSupplierRequestDto requestDto) {
        log.info("addSupplier() called for supplier: {}", requestDto.getSupplierName());

        try {
            String code = generateCode();
            log.debug("Generated supplier code={}", code);
            if (StringUtils.isBlank(requestDto.getSupplierGroup())) {
                requestDto.setSupplierGroup(requestDto.getSupplierName());
            }
            if (StringUtils.isBlank(requestDto.getSupplierMsme())) {
                requestDto.setSupplierMsme("SMALL");
            }
            validateSupplierAndContacts(requestDto, code);
            SupplierEntity entity = supplierMapper.toEntity(requestDto, code);
            log.debug("Supplier entity mapped successfully for code={}", code);

            if (requestDto.getPreferredTransportIds() != null &&
                    !requestDto.getPreferredTransportIds().isEmpty()) {
                log.debug("Mapping preferred transports. count={}", requestDto.getPreferredTransportIds().size());
                Set<TransportEntity> transports = new HashSet<>();
                for (Integer id : requestDto.getPreferredTransportIds()) {
                    log.trace("Fetching transport id={}", id);
                    TransportEntity transport = transportRepo.getReferenceById(id);
                    transports.add(transport);
                }
                entity.setPreferredTransports(transports);
            } else {
                log.debug("No preferred transports provided. Setting empty set");
                entity.setPreferredTransports(Collections.emptySet());
            }
            supplierRepo.save(entity);
            log.info("Supplier '{}' saved successfully with {} contacts",
                    entity.getSupplierName(),
                    entity.getContactList().size());
            return AddSupplierResponseDto.builder()
                    .message("Supplier added successfully")
                    .build();

        } catch (DuplicateEntryException ex) {
            log.warn("Duplicate entry while adding supplier. supplierName={}, error={}",
                    requestDto.getSupplierName(),
                    ex.getMessage());
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

    private String generateCode(){
        Integer maxId = supplierRepo.findMaxCodeSuffix();
        log.info("MAX ID FROM DB = {}", maxId);
        int newId = (maxId != null ? maxId : 0) + 1;
        String code = String.format("S%06d", newId);
        log.info("GENERATED CODE  for supplier = {}", code);
        return code;
    }

    public PagedResponseDto<SupplierListResponseDto> getSuppliers(int page, int size) {
        log.info("[SUPPLIER LIST] Fetch request received | page={} | size={}", page, size);

        Pageable pageable = PageRequest.of(
                page,
                size,
                Sort.by(Sort.Direction.DESC, "createdAt")
        );

        Page<SupplierListResponseDto> records =
                supplierRepo.findSupplierList(StatusEnum.ACTIVE, pageable);

        log.info("[SUPPLIER LIST] Fetch successful | page={} | size={} | fetchedRecords={} | totalRecords={}",
                page,
                size,
                records.getNumberOfElements(),
                records.getTotalElements()
        );

        return PagedResponseDto.<SupplierListResponseDto>builder()
                .content(records.getContent())
                .page(records.getNumber() + 1)
                .size(records.getSize())
                .totalElements(records.getTotalElements())
                .totalPages(records.getTotalPages())
                .last(records.isLast())
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

    @Override
    public PagedResponseDto<SupplierListResponseDto> searchSuppliers(String keyword, Pageable pageable) {

        log.info("SUPPLIER SEARCH Request | keyword='{}' | page={} | size={}",
                keyword,
                pageable.getPageNumber(),
                pageable.getPageSize()
        );

        if (keyword == null || keyword.trim().isEmpty()) {
            return PagedResponseDto.<SupplierListResponseDto>builder()
                    .content(List.of())
                    .page(pageable.getPageNumber() + 1)
                    .size(pageable.getPageSize())
                    .totalElements(0)
                    .totalPages(0)
                    .last(true)
                    .build();
        }

        String trimmedKeyword = keyword.trim();
        log.debug("Searching suppliers with trimmed keyword: '{}'", trimmedKeyword);

        Page<SupplierEntity> suppliersPage =
                supplierRepo.searchByKeyword(trimmedKeyword, pageable);
        List<SupplierListResponseDto> content = suppliersPage.getContent()
                .stream()
                .map(supplierMapper::toListDto)
                .toList();
        log.info("SUPPLIER SEARCH Success | fetched={} | total={}",
                suppliersPage.getNumberOfElements(),
                suppliersPage.getTotalElements()
        );

        return PagedResponseDto.<SupplierListResponseDto>builder()
                .content(content)
                .page(suppliersPage.getNumber() + 1)
                .size(suppliersPage.getSize())
                .totalElements(suppliersPage.getTotalElements())
                .totalPages(suppliersPage.getTotalPages())
                .last(suppliersPage.isLast())
                .build();

    }

    @Override
    public List<SupplierSummaryDto> getAllSuppliers() {

        log.info("[SUPPLIER - ALL] Fetch request received");
        List<SupplierSummaryDto> suppliers = supplierRepo.findAllSummary();
        log.info("[SUPPLIER - ALL] Fetch successful | totalRecords={}", suppliers.size());
        return suppliers;
    }

    @Override
    public void updateSupplier(Integer id, UpdateSupplierRequestDto request) {
        log.info("Update request received for Supplier id={}", id);

        try {
            SupplierEntity entity = supplierRepo.findById(id)
                    .orElseThrow(() -> {
                        log.warn("Supplier not found for update. id={}", id);
                        return new SupplierException(DATA_NOT_FOUND,
                                "Supplier not found with id: " + id);
                    });

            supplierMapper.updateEntity(entity, request);

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
            GetSupplierByIdResponseDto response = supplierMapper.toResponse(entity);

            log.info("Supplier details fetched successfully for id={}", id);

            return response;

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

}
