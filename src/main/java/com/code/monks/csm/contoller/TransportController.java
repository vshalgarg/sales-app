package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.CreateTransportRequest;
import com.code.monks.csm.dto.request.UpdateTransportRequest;
import com.code.monks.csm.dto.response.CreateTransportResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.TransportDto;
import com.code.monks.csm.dto.response.UpdateTransportResponseDto;
import com.code.monks.csm.service.TransportService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
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
    public ResponseEntity<PagedResponseDto<TransportDto>> searchTransports(
            @RequestParam(value = "keyword",required = false) String query,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        log.info("Search transports API called with query: '{}', page: {}, size: {}", query, page, size);

        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.ASC, "name"));

        PagedResponseDto<TransportDto> response = transportService.searchTransports(query, pageable);

        log.info("Search completed - returned {} transports (page {}/{})",
                response.getContent().size(), response.getPage(), response.getTotalPages());

        return ResponseEntity.ok(response);
    }

    @GetMapping(GET_ALL)
    public ResponseEntity<List<TransportDto>> getAll(){
        return ResponseEntity.ok(transportService.getAll());
    }

    @GetMapping(GET_ALL_TRANSPORT)
    public ResponseEntity<Page<TransportDto>> getAllTransports(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "5") int size) {

        Page<TransportDto> transportPage = transportService.getAllTransports(page, size);
        return ResponseEntity.ok(transportPage);
    }

    @PostMapping(ADD_TRANSPORT)
    public ResponseEntity<CreateTransportResponseDto> add(@RequestBody @Valid CreateTransportRequest request) {
        CreateTransportResponseDto response = transportService.add(request);
        return ResponseEntity.ok(response);
    }

    @PutMapping(UPDATE_TRANSPORT)
    public ResponseEntity<UpdateTransportResponseDto> update(@RequestBody UpdateTransportRequest request) {
        UpdateTransportResponseDto response = transportService.update(request);
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
}
