package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.CreateTransportRequest;
import com.code.monks.csm.dto.request.UpdateTransportRequest;
import com.code.monks.csm.dto.response.CreateTransportResponseDto;
import com.code.monks.csm.dto.response.TransportDto;
import com.code.monks.csm.dto.response.UpdateTransportResponseDto;
import com.code.monks.csm.service.TransportService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

import static com.code.monks.csm.constants.ApiPaths.*;

@RestController
@RequestMapping(BASE)
public class TransportController {

    @Autowired
    private TransportService transportService;

    @GetMapping(TRANSPORT_SEARCH)
    public ResponseEntity<List<TransportDto>> search(@RequestParam String query) {
        return ResponseEntity.ok(transportService.searchTransports(query));
    }

    @GetMapping(GET_ALL)
    public ResponseEntity<List<TransportDto>> getAll(){
        return ResponseEntity.ok(transportService.getAll());
    }

    @GetMapping(GET_ALL_TRANSPORT)
    public ResponseEntity<Page<TransportDto>> getAllTransports(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "5") int size) {

        Page<TransportDto> transportPage = transportService.getAllTransports(page, size);
        return ResponseEntity.ok(transportPage);
    }

    @PostMapping(ADD_TRANSPORT)
    public ResponseEntity<CreateTransportResponseDto> add(@RequestBody CreateTransportRequest request) {
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
                "message", "Transport deleted successfully"
        ));
    }

}
