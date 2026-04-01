package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.CreateAndUpdateTransportRequest;
import com.code.monks.csm.dto.response.CommonTransportResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.TransportLiteResponseDto;
import com.code.monks.csm.dto.response.TransportResponseDto;
import com.code.monks.csm.entity.TransportEntity;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;
import java.util.Optional;

public interface TransportService {

    PagedResponseDto<TransportResponseDto> searchTransports(String query, Pageable pageable);
    TransportEntity getOrCreateTransport(String transportName);
    List<TransportLiteResponseDto> getAll();
    PagedResponseDto<TransportResponseDto> getAllTransports(int page, int size);

    CommonTransportResponseDto update(Integer id, CreateAndUpdateTransportRequest request);
    CommonTransportResponseDto add(CreateAndUpdateTransportRequest request);

    void deleteTransport(Integer id);
    Optional<TransportEntity> findByNameIgnoreCase(String name);
}
