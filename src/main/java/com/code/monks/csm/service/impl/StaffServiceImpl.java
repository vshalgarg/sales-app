package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddStaffRequestDto;
import com.code.monks.csm.dto.request.ContactRequestDto;
import com.code.monks.csm.dto.request.DeleteStaffRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.ContactEntity;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.StaffEntity;
import com.code.monks.csm.exception.DuplicateEntryException;
import com.code.monks.csm.exception.StaffException;
import com.code.monks.csm.repository.StaffRepo;
import com.code.monks.csm.service.StaffService;
import com.code.monks.csm.utils.ContactUtil;
import com.code.monks.csm.utils.ValidatorUtil;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import static com.code.monks.csm.enums.ResponseErrorCode.*;
import static com.code.monks.csm.enums.StatusEnum.ACTIVE;
import static com.code.monks.csm.enums.StatusEnum.INACTIVE;

@Service
@AllArgsConstructor
@Slf4j
public class StaffServiceImpl implements StaffService {

    private final StaffRepo staffRepo;

    private final ValidatorUtil validatorUtil;

    @Override
    public AddStaffResponseDto addStaff(AddStaffRequestDto requestDto) {
        log.info("addStaff() called with name: {}", requestDto.getStaffName());

        try {
            // Step 1: Validate request
            validateStaff(requestDto);

            // Step 2: Map DTO to entity
            StaffEntity entity = AddStaffResponseDto.dtoToEntity(requestDto);

            // Step 3: Save to repository
            staffRepo.save(entity);
            log.info("Staff saved successfully with id: {}", entity.getId());

            return AddStaffResponseDto.builder()
                    .message("Staff added successfully")
                    .build();

        } catch (DuplicateEntryException ex) {
            log.warn("Staff validation failed for '{}': {}", requestDto.getPhone(), ex.getMessage());
            throw ex;
        }catch (Exception e) {
            log.error("Error while adding staff '{}'", requestDto.getStaffName(), e);
            throw new StaffException(UNEXPECTED_EXCEPTION,e.getMessage());
        }
    }

    private void validateStaff(AddStaffRequestDto requestDto) {
        List<ValidatorUtil.DuplicateCheck> duplicateChecks = new ArrayList<>();

        duplicateChecks.add(new ValidatorUtil.DuplicateCheck(
                "phone", () -> staffRepo.existsByPhone(requestDto.getPhone())
        ));
        validatorUtil.validateUniqueFields(duplicateChecks);
    }

    @Override
    public PagedResponseDto<GetStaffDto> getStaff(int page, int size) {
        log.info("Fetching active staffs with pagination...");

        try {
            Pageable pageable = PageRequest.of(page - 1, size, Sort.by(Sort.Direction.DESC, "id"));
            Page<StaffEntity> records = staffRepo.findAllByStatus(pageable, ACTIVE);

            log.debug("Fetched {} active staff records (page {}/{})",
                    records.getNumberOfElements(), page, records.getTotalPages());

            List<GetStaffDto> dtoList = records.getContent()
                    .stream()
                    .map(this::mapToDto) // Assuming you have mapToDto(StaffEntity)
                    .collect(Collectors.toList());

            return PagedResponseDto.<GetStaffDto>builder()
                    .content(dtoList)
                    .page(records.getNumber() + 1) // convert back to 1-based index
                    .size(records.getSize())
                    .totalElements(records.getTotalElements())
                    .totalPages(records.getTotalPages())
                    .last(records.isLast())
                    .build();

        } catch (DataAccessException dae) {
            log.error("Database error occurred while fetching active staff members: {}", dae.getMessage(), dae);
            throw new StaffException(DATA_ACCESS_ERROR, dae.getMessage());
        } catch (Exception ex) {
            log.error("Unexpected error occurred while fetching active staff members: {}", ex.getMessage(), ex);
            throw new StaffException(UNEXPECTED_EXCEPTION, ex.getMessage());
        }
    }


    private GetStaffDto mapToDto(StaffEntity record) {
        log.debug("Mapping StaffEntity with code={} to DTO", record.getStaffName());

        return GetStaffDto.builder()
                .staffId(record.getId())
                .staffName(record.getStaffName())
                .phone(record.getPhone())
                .joiningDate(record.getJoiningDate())
                .build();
    }

    public DeleteStaffResponseDto deleteStaff(DeleteStaffRequestDto requestDto) {
        int staffId = requestDto.getStaffId();
        log.info("deleteStaff() called for staffId: {}", staffId);

        try {
            // 🔹 Step 1: Fetch staff record
            StaffEntity entity = staffRepo.findById(staffId)
                    .orElseThrow(() -> {
                        log.warn("Staff with ID {} not found for deletion", staffId);
                        return new StaffException(DATA_NOT_FOUND);
                    });

            log.debug("Staff found: {} (Status: {})", entity.getStaffName(), entity.getStatus());

            // 🔹 Step 2: Set status to INACTIVE
            entity.setStatus(INACTIVE);
            staffRepo.save(entity);
            log.info("Staff ID {} status updated to INACTIVE successfully", staffId);

            // 🔹 Step 3: Return response
            return DeleteStaffResponseDto.builder()
                    .message("Staff ID: " + staffId + " became INACTIVE")
                    .build();

        } catch (DataAccessException dae) {
            log.error("Database error while deactivating staff with ID {}: {}", staffId, dae.getMessage(), dae);
            throw new StaffException(DATA_ACCESS_ERROR, dae.getMessage());

        } catch (StaffException se) {
            throw se;

        } catch (Exception ex) {
            log.error("Unexpected error occurred while deleting staff with ID {}: {}", staffId, ex.getMessage(), ex);
            throw new StaffException(UNEXPECTED_EXCEPTION, ex.getMessage());
        }
    }

    public List<SearchStaffsResponseDto> searchStaffs(String keyword){
        List<StaffEntity> records = staffRepo.findByStaffNameContainingIgnoreCaseAndStatus(keyword, ACTIVE);
        return records.stream().map((s) -> {
            return SearchStaffsResponseDto.builder()
                    .staffId(s.getId())
                    .staffName(s.getStaffName())
                    .phone(s.getPhone())
                    .joiningDate(s.getJoiningDate()).build();
        }).toList();
    }

}
