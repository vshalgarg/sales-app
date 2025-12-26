package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.CreateTransportRequest;
import com.code.monks.csm.dto.request.UpdateTransportRequest;
import com.code.monks.csm.dto.response.CreateTransportResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.TransportDto;
import com.code.monks.csm.dto.response.UpdateTransportResponseDto;
import com.code.monks.csm.entity.TransportEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface TransportService {

    PagedResponseDto<TransportDto> searchTransports(String query, Pageable pageable);
    TransportEntity getOrCreateTransport(String transportName);
    List<TransportDto> getAll();
    Page<TransportDto> getAllTransports(int page, int size);

    UpdateTransportResponseDto update(UpdateTransportRequest request);
    CreateTransportResponseDto add(CreateTransportRequest request);

    void deleteTransport(Integer id);
    Optional<TransportEntity> findByNameIgnoreCase(String name);
}
