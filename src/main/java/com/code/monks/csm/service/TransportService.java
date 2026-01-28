package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.CreateTransportRequest;
import com.code.monks.csm.dto.request.UpdateTransportRequest;
import com.code.monks.csm.dto.response.CommonTransportResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.TransportDto;
import com.code.monks.csm.dto.response.TransportResponseDto;
import com.code.monks.csm.entity.TransportEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface TransportService {

    PagedResponseDto<TransportResponseDto> searchTransports(String query, Pageable pageable);
    TransportEntity getOrCreateTransport(String transportName);
    List<TransportResponseDto> getAll();
    Page<TransportResponseDto> getAllTransports(int page, int size);

    CommonTransportResponseDto update(Integer id, UpdateTransportRequest request);
    CommonTransportResponseDto add(CreateTransportRequest request);

    void deleteTransport(Integer id);
    Optional<TransportEntity> findByNameIgnoreCase(String name);
}
