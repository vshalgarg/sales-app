package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.CreateTransportRequest;
import com.code.monks.csm.dto.request.UpdateTransportRequest;
import com.code.monks.csm.dto.response.CreateTransportResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.TransportDto;
import com.code.monks.csm.dto.response.UpdateTransportResponseDto;
import com.code.monks.csm.entity.TransportEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.repository.TransportRepository;
import com.code.monks.csm.service.TransportService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import static com.code.monks.csm.enums.ResponseErrorCode.TRANSPORT_NOT_FOUND;

@Service
@Slf4j
@RequiredArgsConstructor
public class TransportServiceImpl implements TransportService {

    private final TransportRepository transportRepository;


    @Override
    public CreateTransportResponseDto add(CreateTransportRequest request) {

        String name = request.getName().trim();
        String contact = request.getContactNumber().trim();
        String gst = request.getGstNo() != null ? request.getGstNo().trim() : null;

        if (name.isEmpty()) {
            return createFailure("Transport name is required");
        }
        Optional<String> duplicateError =
                validateDuplicate(name, contact, gst, null);
        if (duplicateError.isPresent()) {
            return createFailure(duplicateError.get());
        }

        TransportEntity transport = new TransportEntity();
        transport.setName(request.getName().trim());
        transport.setStatus(StatusEnum.ACTIVE); // new transport always active
        transport.setContactNumber(request.getContactNumber());
        transport.setCity(request.getCity());
        transport.setGstNo(request.getGstNo());
        transport.setAddress(request.getAddress());

        TransportEntity savedTransport = transportRepository.save(transport);

        CreateTransportResponseDto response = new CreateTransportResponseDto();
        response.setId(savedTransport.getId());
        response.setName(savedTransport.getName());
        response.setSuccess(true);
        response.setMessage("Transport added successfully");

        return response;
    }


    @Override
    public UpdateTransportResponseDto update(UpdateTransportRequest request) {

        TransportEntity transport = transportRepository.findById(request.getId())
                .orElse(null);
        if (transport == null) {
            return updateFailure("Transport not found with id: " + request.getId());
        }
        String name = request.getName().trim();
        String contact = request.getContactNumber().trim();
        String gst = request.getGstNo() != null ? request.getGstNo().trim() : null;

        Optional<String> duplicateError =
                validateDuplicate(name, contact, gst, request.getId());

        if (duplicateError.isPresent()) {
            return updateFailure(duplicateError.get());
        }

        transport.setName(name);
        transport.setContactNumber(contact);
        transport.setGstNo(gst);
        transport.setCity(request.getCity());
        transport.setAddress(request.getAddress());
        transport.setStatus(request.getStatus());
        TransportEntity updatedTransport = transportRepository.save(transport);

        UpdateTransportResponseDto response = new UpdateTransportResponseDto();
        response.setId(updatedTransport.getId());
        response.setName(updatedTransport.getName());
        response.setSuccess(true);
        response.setMessage("Transport updated successfully");
        return response;
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
    public PagedResponseDto<TransportDto> searchTransports(String query, Pageable pageable) {
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
            List<TransportDto> dtoList = transportPage.getContent().stream()
                    .map(entity -> {
                        log.debug("Mapping TransportEntity id:{} name:'{}' to DTO", entity.getId(), entity.getName());
                        return TransportDto.builder()
                                .id(entity.getId())
                                .name(entity.getName())
                                .gstNo(entity.getGstNo())
                                .address(entity.getAddress())
                                .contactNumber(entity.getContactNumber())
                                .city(entity.getCity())
                                .status(entity.getStatus())
                                .build();
                    })
                    .toList();

            return PagedResponseDto.<TransportDto>builder()
                    .content(dtoList)
                    .page(transportPage.getNumber() + 1) // 1-based for UI
                    .size(transportPage.getSize())
                    .totalElements(transportPage.getTotalElements())
                    .totalPages(transportPage.getTotalPages())
                    .last(transportPage.isLast())
                    .build();
    }

    @Override
    @Transactional
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
    public List<TransportDto> getAll() {
        log.info("Fetching all transport records...");
            List<TransportEntity> transportList = transportRepository.findAll(
                    Sort.by(Sort.Direction.DESC, "id")
            );
            log.info("Successfully fetched {} transport records", transportList.size());
            List<TransportDto> res = transportList.stream()
                    .map(t -> {
                        log.debug("Mapping TransportEntity with id:{} and name:'{}' to DTO",
                                t.getId(), t.getName());
                        TransportDto dto = new TransportDto();
                        dto.setId(t.getId());
                        dto.setName(t.getName());
                        dto.setContactNumber(t.getContactNumber());
                        dto.setAddress(t.getAddress());
                        dto.setStatus(t.getStatus());
                        dto.setGstNo(t.getGstNo());
                        dto.setCity(t.getCity());
                        return dto;
                    })
                    .collect(Collectors.toList());

            log.info("Successfully mapped and returning {} TransportDto objects", res.size());
            return res;
    }
    public Page<TransportDto> getAllTransports(int page, int size) {
        log.info("Fetching all transport records... with pagination");
        Pageable pageable = PageRequest.of(
                page,
                size,
                Sort.by(Sort.Direction.DESC, "createdAt")
        );

        Page<TransportEntity> transportPage = transportRepository
                .findAllByStatusNot(StatusEnum.DELETE, pageable);
        log.info("Found {} transports (ACTIVE+INACTIVE only)", transportPage.getTotalElements());
        return transportPage.map(this::convertToDto);
    }

    private TransportDto convertToDto(TransportEntity t) {
        TransportDto dto = new TransportDto();
        dto.setId(t.getId());
        dto.setName(t.getName());
        dto.setContactNumber(t.getContactNumber());
        dto.setAddress(t.getAddress());
        dto.setStatus(t.getStatus());
        dto.setGstNo(t.getGstNo());
        dto.setCity(t.getCity());
        return dto;
    }

    public Optional<TransportEntity> findByNameIgnoreCase(String name) {
        return transportRepository.findByNameIgnoreCase(name);
    }

    private Optional<String> validateDuplicate(
            String name,
            String contact,
            String gst,
            Integer excludeId // null for CREATE
    ) {

        if (excludeId == null) {
            // CREATE
            if (transportRepository.existsByNameIgnoreCase(name)) {
                return Optional.of("Transport name already exists");
            }
            if (transportRepository.existsByContactNumber(contact)) {
                return Optional.of("Contact number already exists");
            }
            if (gst != null && !gst.isEmpty()
                    && transportRepository.existsByGstNoIgnoreCase(gst)) {
                return Optional.of("GST number already exists");
            }
        } else {
            // UPDATE
            if (transportRepository.existsByNameIgnoreCaseAndIdNot(name, excludeId)) {
                return Optional.of("Transport name already exists");
            }
            if (transportRepository.existsByContactNumberAndIdNot(contact, excludeId)) {
                return Optional.of("Contact number already exists");
            }
            if (gst != null && !gst.isEmpty()
                    && transportRepository.existsByGstNoIgnoreCaseAndIdNot(gst, excludeId)) {
                return Optional.of("GST number already exists");
            }
        }

        return Optional.empty();
    }

    private CreateTransportResponseDto createFailure(String message) {
        CreateTransportResponseDto res = new CreateTransportResponseDto();
        res.setSuccess(false);
        res.setMessage(message);
        return res;
    }

    private UpdateTransportResponseDto updateFailure(String message) {
        UpdateTransportResponseDto res = new UpdateTransportResponseDto();
        res.setSuccess(false);
        res.setMessage(message);
        return res;
    }
}
