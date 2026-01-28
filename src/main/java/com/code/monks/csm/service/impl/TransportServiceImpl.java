package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.CreateTransportRequest;
import com.code.monks.csm.dto.request.UpdateTransportRequest;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.TransportContactEntity;
import com.code.monks.csm.entity.TransportEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.exception.DuplicateEntryException;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.repository.TransportRepository;
import com.code.monks.csm.service.TransportService;
import com.code.monks.csm.utils.DuplicateConstraintResolver;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import static com.code.monks.csm.enums.ResponseErrorCode.DUPLICATE_ENTRY;
import static com.code.monks.csm.enums.ResponseErrorCode.TRANSPORT_NOT_FOUND;

@Service
@Slf4j
@RequiredArgsConstructor
public class TransportServiceImpl implements TransportService {

    private final TransportRepository transportRepository;


    @Override
    public CommonTransportResponseDto add(CreateTransportRequest request) {

        try {
            String name  = request.getName().trim();
            String email = normalize(request.getEmail());
            String gst   = normalize(request.getGstNo());

            TransportEntity transport = new TransportEntity();
            transport.setName(name);
            transport.setEmail(email);
            transport.setGstNo(gst);
            transport.setState(request.getState());
            transport.setCity(request.getCity());
            transport.setAddressLine1(request.getAddressLine1());
            transport.setAddressLine2(request.getAddressLine2());
            transport.setStatus(StatusEnum.ACTIVE);

            List<TransportContactEntity> contacts =
                    request.getContacts().stream()
                            .map(c -> {
                                TransportContactEntity contact = new TransportContactEntity();
                                contact.setContactPerson(c.getContactPerson());
                                contact.setContactNumber(c.getContactNumber());
                                contact.setTransport(transport);
                                return contact;
                            })
                            .toList();
            transport.setContacts(contacts);


            TransportEntity savedTransport = transportRepository.save(transport);

            CommonTransportResponseDto response = new CommonTransportResponseDto();
            response.setSuccess(true);
            response.setMessage("Transport added successfully");
            response.setId(savedTransport.getId());

            return response;
        }
        catch (DataIntegrityViolationException ex) {
            DuplicateConstraintResolver.handle(ex);
            return null;
        }
    }


    @Override
    public CommonTransportResponseDto update(Integer id, UpdateTransportRequest request) {

        try{
        TransportEntity transport = transportRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(TRANSPORT_NOT_FOUND,""));
        String name = request.getName().trim();
            String email = normalize(request.getEmail());
            String gst   = normalize(request.getGstNo());

        transport.setName(name);
        transport.setEmail(email);
        transport.setGstNo(gst);
        transport.setState(request.getState());
        transport.setCity(request.getCity());
        transport.setAddressLine1(request.getAddressLine1());
        transport.setAddressLine2(request.getAddressLine2());
        transport.setStatus(request.getStatus());

        transport.getContacts().clear();

        List<TransportContactEntity> contacts =
                request.getContacts().stream()
                        .map(c -> {
                            TransportContactEntity contact = new TransportContactEntity();
                            contact.setContactPerson(c.getContactPerson());
                            contact.setContactNumber(c.getContactNumber());
                            contact.setTransport(transport);
                            return contact;
                        })
                        .toList();

        transport.getContacts().addAll(contacts);

        transportRepository.save(transport);

        CommonTransportResponseDto response = new CommonTransportResponseDto();
        response.setSuccess(true);
        response.setMessage("Transport updated successfully");
        response.setId(transport.getId());

        return response;
    }
        catch (DataIntegrityViolationException ex) {
            DuplicateConstraintResolver.handle(ex);
            return null;
        }

    }

    public void deleteTransport(Integer id) {
        log.info("Attempting to soft delete transport with ID: {}", id);
        TransportEntity transport = transportRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(TRANSPORT_NOT_FOUND, "Transport not found"));
        log.info("Found transport '{}' (ID: {}) for deletion", transport.getName(), id);

        StatusEnum oldStatus = transport.getStatus();
        log.debug("Transport current status before delete: {}", oldStatus);
        transport.setStatus(StatusEnum.DELETE);
        transportRepository.save(transport);
        log.info("Transport '{}' (ID: {}) soft deleted successfully. Status changed from {} to DELETE",
                transport.getName(), id, oldStatus);
    }


    @Override
    public PagedResponseDto<TransportResponseDto> searchTransports(String query, Pageable pageable) {
        log.info("Search transports called - query: '{}', pageable: {}", query, pageable);

        Page<TransportEntity> transportPage;

        if (query == null || query.trim().isEmpty()) {
            //EMPTY RESULTS
            log.info("Empty query provided - returning empty results");
            transportPage = Page.empty(pageable);
        } else {
            String trimmedQuery = query.trim();
            log.info("Searching with trimmed query: '{}'", trimmedQuery);
            transportPage = transportRepository.searchByName(trimmedQuery,StatusEnum.ACTIVE, pageable);
        }

            log.info("Search completed - found {} transports (page {}/{})",
                    transportPage.getNumberOfElements(),
                    transportPage.getNumber() + 1,
                    transportPage.getTotalPages());

            // Map to DTOs
        List<TransportResponseDto> dtoList =
                transportPage.getContent().stream()
                        .map(this::convertToResponseDto)
                        .toList();

            return PagedResponseDto.<TransportResponseDto>builder()
                    .content(dtoList)
                    .page(transportPage.getNumber() + 1) // 1-based for UI
                    .size(transportPage.getSize())
                    .totalElements(transportPage.getTotalElements())
                    .totalPages(transportPage.getTotalPages())
                    .last(transportPage.isLast())
                    .build();
    }

    @Override
    public TransportEntity getOrCreateTransport(String transportName) {
        if (transportName == null || transportName.trim().isEmpty()) {
            return null;
        }

        String trimmed = transportName.trim();

        return transportRepository.findByNameIgnoreCase(trimmed)
                .orElseGet(() -> {
                    TransportEntity newTransport = new TransportEntity();
                    newTransport.setName(trimmed);
                    newTransport.setStatus(StatusEnum.ACTIVE);
                    return transportRepository.save(newTransport);
                });
    }

    @Override
    public List<TransportResponseDto> getAll() {

        log.info("Fetching all transport records...");

        List<TransportEntity> transportList =
                transportRepository.findAll(
                        Sort.by(Sort.Direction.DESC, "id")
                );

        log.info("Successfully fetched {} transport records", transportList.size());

        List<TransportResponseDto> result =
                transportList.stream()
                        .map(this::convertToResponseDto)
                        .toList();

        log.info("Successfully mapped {} transport records", result.size());
        return result;
    }

    @Override
    public Page<TransportResponseDto> getAllTransports(int page, int size) {

        log.info("Fetching transports with pagination (page={}, size={})", page, size);

        Pageable pageable = PageRequest.of(
                page,
                size,
                Sort.by(Sort.Direction.DESC, "createdAt")
        );

        Page<TransportEntity> transportPage =
                transportRepository.findAllByStatusNot(
                        StatusEnum.DELETE,
                        pageable
                );

        log.info("Found {} transports", transportPage.getTotalElements());

        return transportPage.map(this::convertToResponseDto);
    }



    private TransportResponseDto convertToResponseDto(TransportEntity t) {

        TransportResponseDto dto = new TransportResponseDto();
        dto.setId(t.getId());
        dto.setName(t.getName());
        dto.setEmail(t.getEmail());
        dto.setGstNo(t.getGstNo());
        dto.setState(t.getState());
        dto.setCity(t.getCity());
        dto.setAddressLine1(t.getAddressLine1());
        dto.setAddressLine2(t.getAddressLine2());
        dto.setStatus(t.getStatus());

        List<TransportContactResponseDto> contacts =
                t.getContacts().stream()
                        .map(c -> {
                            TransportContactResponseDto cd = new TransportContactResponseDto();
                            cd.setContactPerson(c.getContactPerson());
                            cd.setContactNumber(c.getContactNumber());
                            return cd;
                        })
                        .toList();

        dto.setContacts(contacts);

        return dto;
    }


    public Optional<TransportEntity> findByNameIgnoreCase(String name) {
        return transportRepository.findByNameIgnoreCase(name);
    }

    private String normalize(String value) {
        if (value == null) return null;

        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }


//    private Optional<String> validateDuplicate(
//            String name,
//            String contact,
//            String gst,
//            Integer excludeId // null for CREATE
//    ) {
//
//        if (excludeId == null) {
//            // CREATE
//            if (transportRepository.existsByNameIgnoreCase(name)) {
//                return Optional.of("Transport name already exists");
//            }
//            if (transportRepository.existsByContactNumber(contact)) {
//                return Optional.of("Contact number already exists");
//            }
//            if (gst != null && !gst.isEmpty()
//                    && transportRepository.existsByGstNoIgnoreCase(gst)) {
//                return Optional.of("GST number already exists");
//            }
//        } else {
//            // UPDATE
//            if (transportRepository.existsByNameIgnoreCaseAndIdNot(name, excludeId)) {
//                return Optional.of("Transport name already exists");
//            }
//            if (transportRepository.existsByContactNumberAndIdNot(contact, excludeId)) {
//                return Optional.of("Contact number already exists");
//            }
//            if (gst != null && !gst.isEmpty()
//                    && transportRepository.existsByGstNoIgnoreCaseAndIdNot(gst, excludeId)) {
//                return Optional.of("GST number already exists");
//            }
//        }
//
//        return Optional.empty();
//    }
}
