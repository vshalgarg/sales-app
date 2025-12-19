package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.CreateTransportRequest;
import com.code.monks.csm.dto.request.UpdateTransportRequest;
import com.code.monks.csm.dto.response.CreateTransportResponseDto;
import com.code.monks.csm.dto.response.TransportDto;
import com.code.monks.csm.dto.response.UpdateTransportResponseDto;
import com.code.monks.csm.entity.TransportEntity;
import org.springframework.data.domain.Page;

import java.util.List;
import java.util.Optional;

public interface TransportService {

    List<TransportDto> searchTransports(String query);
    TransportEntity getOrCreateTransport(String transportName);
    List<TransportDto> getAll();
    Page<TransportDto> getAllTransports(int page, int size);

    UpdateTransportResponseDto update(UpdateTransportRequest request);
    CreateTransportResponseDto add(CreateTransportRequest request);

    void deleteTransport(Integer id);
    Optional<TransportEntity> findByNameIgnoreCase(String name);
}
