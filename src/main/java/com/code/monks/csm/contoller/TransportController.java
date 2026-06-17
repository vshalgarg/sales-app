package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.CreateAndUpdateTransportRequest;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.TransportService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

import static com.code.monks.csm.constants.ApiPaths.*;

@RestController
@RequestMapping(BASE)
@Slf4j
@RequiredArgsConstructor
public class TransportController {

    private final TransportService transportService;

    @GetMapping(TRANSPORT_SEARCH)
    public ResponseEntity<PagedResponseDto<TransportResponseDto>> searchTransports(
            @RequestParam(value = "keyword",required = false) String query,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        log.info("Search transports API called with query: '{}', page: {}, size: {}", query, page, size);

        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "name"));

        PagedResponseDto<TransportResponseDto> response = transportService.searchTransports(query, pageable);

        log.info("Search completed - returned {} transports (page {}/{})",
                response.getContent().size(), response.getPage(), response.getTotalPages());

        return ResponseEntity.ok(response);
    }

    @GetMapping(GET_ALL)
    public ResponseEntity<List<TransportLiteResponseDto>> getAll(){
        return ResponseEntity.ok(transportService.getAll());
    }

    @GetMapping(GET_ALL_TRANSPORT)
    public ResponseEntity<PagedResponseDto<TransportResponseDto>> getAllTransports(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size) {

        PagedResponseDto<TransportResponseDto> transportPage = transportService.getAllTransports(page, size);
        return ResponseEntity.ok(transportPage);
    }

    @PostMapping(ADD_TRANSPORT)
    public ResponseEntity<CommonTransportResponseDto> add(
            @RequestBody @Valid CreateAndUpdateTransportRequest request) {

        CommonTransportResponseDto response = transportService.add(request);
        return ResponseEntity.ok(response);
    }

    @PutMapping(UPDATE_TRANSPORT)
    public ResponseEntity<CommonTransportResponseDto> update(
            @PathVariable Integer id,
            @RequestBody @Valid CreateAndUpdateTransportRequest request) {

        CommonTransportResponseDto response = transportService.update(id, request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping(DELETE_TRANSPORT)
    public ResponseEntity<?> deleteTransport(@PathVariable Integer id) {
        transportService.deleteTransport(id);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "message", "Transport marked as deleted"
        ));
    }

    @GetMapping(GET_TRANSPORT_DETAILS)
    public TransportDetailsResponseDTO getTransportDetails(
            @PathVariable Integer id
    ) {
        log.info("Received request to get transport details for id: {}", id);
        return transportService.getTransportDetails(id);
    }
}
