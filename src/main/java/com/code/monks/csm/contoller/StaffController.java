package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.AddStaffRequestDto;
import com.code.monks.csm.dto.request.DeleteStaffRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.StaffService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.code.monks.csm.constants.ApiPaths.*;

@RequestMapping(BASE)
@RestController
@AllArgsConstructor
@Slf4j
public class StaffController {

    private final StaffService staffService;

    @PostMapping(ADD_STAFF)
    public ResponseEntity<AddStaffResponseDto> addStaff(@Valid @RequestBody AddStaffRequestDto requestDto) {
        log.info("ADD_STAFF API called with staff name: {}", requestDto.getStaffName());

        AddStaffResponseDto response = staffService.addStaff(requestDto);

        log.info("ADD_STAFF API completed for name: {}", requestDto.getStaffName());
        return ResponseEntity.ok(response);
    }

    @GetMapping(GET_STAFF)
    public ResponseEntity<PagedResponseDto<GetStaffDto>> getStaff(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "8") int size
    ) {
        log.info("GET staff API called to retrieve customers (page={}, size={})", page, size);

        PagedResponseDto<GetStaffDto> response = staffService.getStaff(page,size);

        log.info("Retrieved {} staffs successfully", response.getContent().size());
        return ResponseEntity.ok(response);
    }

    @PutMapping(DELETE_STAFF)
    public ResponseEntity<DeleteStaffResponseDto> deleteStaff(@Valid @RequestBody DeleteStaffRequestDto requestDto) {
        log.info("DELETE_STAFF API called for staffId: {}", requestDto.getStaffId());

        DeleteStaffResponseDto response = staffService.deleteStaff(requestDto);

        log.info("DELETE_STAFF API completed for staffId: {} with message: {}", requestDto.getStaffId(), response.getMessage());
        return ResponseEntity.ok(response);
    }

    @GetMapping(SEARCH_STAFFS)
    public ResponseEntity<PagedResponseDto<SearchStaffsResponseDto>> searchStaffs(
            @RequestParam(value = "keyword", required = false, defaultValue = "") String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "8") int size
    ) {
        String trimmedKeyword = (keyword != null ? keyword.trim() : "");
        Pageable pageable = PageRequest.of(page, size);
        PagedResponseDto<SearchStaffsResponseDto> responseDto = staffService.searchStaffs(trimmedKeyword,pageable);
        return ResponseEntity.ok(responseDto);
    }
}
