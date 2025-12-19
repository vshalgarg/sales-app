package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.CreateTransportRequest;
import com.code.monks.csm.dto.request.UpdateTransportRequest;
import com.code.monks.csm.dto.response.CreateTransportResponseDto;
import com.code.monks.csm.dto.response.TransportDto;
import com.code.monks.csm.dto.response.UpdateTransportResponseDto;
import com.code.monks.csm.entity.TransportEntity;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.repository.TransportRepository;
import com.code.monks.csm.service.TransportService;
import org.springframework.beans.factory.annotation.Autowired;
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
public class TransportServiceImpl implements TransportService {

    @Autowired
    private TransportRepository transportRepository;

    @Override
    public List<TransportDto> searchTransports(String query) {
        List<TransportEntity> entities;
        if (query == null || query.trim().length() < 1) {
            entities = transportRepository.findAllByIsActiveTrueOrderByNameAsc();
        } else {
            entities = transportRepository.searchByName(query.trim());
        }
        return entities.stream()
                .map(entity -> TransportDto.builder()
                        .id(entity.getId())
                        .name(entity.getName())
                        .isActive(entity.getIsActive())
                        .build())
                .toList();
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
                    newTransport.setIsActive(true);
                    return transportRepository.save(newTransport);
                });
    }

    @Override
    public List<TransportDto> getAll() {

       List<TransportEntity> transportList = transportRepository.findAll();
        List<TransportDto> res = transportList.stream()
               .map(t-> {
                   TransportDto dto = new TransportDto();
                   dto.setId(t.getId());
                   dto.setName(t.getName());
                   return dto;
               })
               .collect(Collectors.toList());
        return res;
    }

    public Page<TransportDto> getAllTransports(int page, int size) {
        Pageable pageable = PageRequest.of(
                page - 1,
                size,
                Sort.by(Sort.Direction.DESC, "createdAt")
        );

        Page<TransportEntity> transportPage = transportRepository.findAll(pageable);
        return transportPage.map(this::convertToDto);
    }


    @Override
    public UpdateTransportResponseDto update(UpdateTransportRequest request) {

       Optional<TransportEntity> transportOpt = transportRepository.findById(request.getId());
        if (transportOpt.isEmpty()) {
            UpdateTransportResponseDto response = new UpdateTransportResponseDto();
            response.setSuccess(false);
            response.setMessage("Transport not found with id: " + request.getId());
            return response;
        }

        TransportEntity transport = transportOpt.get();
        transport.setName(request.getName().trim());
        transport.setIsActive(request.getIsActive());
        TransportEntity updatedTransport = transportRepository.save(transport);

        UpdateTransportResponseDto response = new UpdateTransportResponseDto();
        response.setId(updatedTransport.getId());
        response.setName(updatedTransport.getName());
        response.setIsActive(updatedTransport.getIsActive());
        response.setSuccess(true);
        response.setMessage("Transport updated successfully");
        return response;
    }


    @Override
    public CreateTransportResponseDto add(CreateTransportRequest request) {

        if (request.getName() == null || request.getName().trim().isEmpty()) {
            CreateTransportResponseDto response = new CreateTransportResponseDto();
            response.setSuccess(false);
            response.setMessage("Transport name is required.");
            return response;
        }

         if (transportRepository.existsByNameIgnoreCase(request.getName().trim())) {
             CreateTransportResponseDto response = new CreateTransportResponseDto();
             response.setSuccess(false);
             response.setMessage("Transport with this name already exists.");
             return response;
         }

        TransportEntity transport = new TransportEntity();
        transport.setName(request.getName().trim());
        transport.setIsActive(true); // new transport always active

        if (request.getIsActive() != null) {
            transport.setIsActive(request.getIsActive());
        }

        TransportEntity savedTransport = transportRepository.save(transport);

        CreateTransportResponseDto response = new CreateTransportResponseDto();
        response.setId(savedTransport.getId());
        response.setName(savedTransport.getName());
        response.setIsActive(savedTransport.getIsActive());
        response.setSuccess(true);
        response.setMessage("Transport added successfully");

        return response;
    }

    public void deleteTransport(Integer id) {
        TransportEntity transport = transportRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(TRANSPORT_NOT_FOUND, "Failed to delete transport"));
        transportRepository.delete(transport);
    }

    private TransportDto convertToDto(TransportEntity t) {
        TransportDto dto = new TransportDto();
        dto.setId(t.getId());
        dto.setName(t.getName());
        dto.setIsActive(t.getIsActive());
        return dto;
    }

    public Optional<TransportEntity> findByNameIgnoreCase(String name) {
        return transportRepository.findByNameIgnoreCase(name);
    }
}
