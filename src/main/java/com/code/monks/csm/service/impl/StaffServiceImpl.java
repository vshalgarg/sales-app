package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddStaffRequestDto;
import com.code.monks.csm.dto.request.ContactRequestDto;
import com.code.monks.csm.dto.request.DeleteStaffRequestDto;
import com.code.monks.csm.dto.request.UpdateStaffRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.ContactEntity;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.StaffEntity;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.exception.DuplicateEntryException;
import com.code.monks.csm.exception.ResourceNotFoundException;
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
           // validateStaff(requestDto);

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
            throw new StaffException(UNEXPECTED_EXCEPTION," adding staff");
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
            Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "id"));
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
            throw new StaffException(UNEXPECTED_EXCEPTION,  " fetching active staff members.");
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
            throw new StaffException(UNEXPECTED_EXCEPTION, "deleting staff");
        }
    }

    public PagedResponseDto<SearchStaffsResponseDto> searchStaffs(String keyword, Pageable pageable) {

        if (keyword == null || keyword.trim().isEmpty()) {
            log.info("Keyword is empty or null - returning empty page");
            return PagedResponseDto.<SearchStaffsResponseDto>builder()
                    .content(List.of())
                    .page(pageable.getPageNumber() + 1)
                    .size(pageable.getPageSize())
                    .totalElements(0L)
                    .totalPages(0)
                    .last(true)
                    .build();
        }

        String trimmedKeyword = keyword.trim();
        log.debug("Searching staffs with keyword: '{}'", trimmedKeyword);

        try {
            Page<StaffEntity> staffPage = staffRepo.findByStaffNameContainingIgnoreCaseAndStatus(
                    trimmedKeyword,
                    StatusEnum.ACTIVE,
                    pageable
            );

            log.info("Search completed - found {} staffs (page {}/{}, total: {})",
                    staffPage.getNumberOfElements(),
                    staffPage.getNumber() + 1,
                    staffPage.getTotalPages(),
                    staffPage.getTotalElements());

            List<SearchStaffsResponseDto> dtoList = staffPage.getContent()
                    .stream()
                    .map(this::convertToDto)
                    .collect(Collectors.toList());
            return PagedResponseDto.<SearchStaffsResponseDto>builder()
                    .content(dtoList)
                    .page(staffPage.getNumber() + 1)
                    .size(staffPage.getSize())
                    .totalElements(staffPage.getTotalElements())
                    .totalPages(staffPage.getTotalPages())
                    .last(staffPage.isLast())
                    .build();

        } catch (Exception e) {
            log.error("Error while searching staffs with keyword: '{}'", trimmedKeyword, e);
            throw new StaffException(UNEXPECTED_EXCEPTION);
        }
    }

    @Override
    public List<GetStaffDto> getAllActiveStaff() {
        log.info("Fetching all active staffs (no pagination)...");

        try {
            // Using the overloaded method with Sort
            List<StaffEntity> records = staffRepo.findAllByStatus(
                    Sort.by(Sort.Direction.DESC, "id"),
                    StatusEnum.ACTIVE
            );

            log.debug("Fetched {} active staff records", records.size());

            return records.stream()
                    .map(this::mapToDto)
                    .collect(Collectors.toList());

        } catch (DataAccessException dae) {
            log.error("Database error while fetching all active staff: {}", dae.getMessage(), dae);
            throw new StaffException(DATA_ACCESS_ERROR, dae.getMessage());
        } catch (Exception ex) {
            log.error("Unexpected error while fetching all active staff: {}", ex.getMessage(), ex);
            throw new StaffException(UNEXPECTED_EXCEPTION, ex.getMessage());
        }
    }

    @Override
    public GetStaffDto getStaffById(Integer staffId) {
        log.info("getStaffById() called for staffId: {}", staffId);
        StaffEntity staff = staffRepo.findById(staffId)
                .orElseThrow(() -> {
                    log.warn("Staff not found with id: {}", staffId);
                    return new StaffException(DATA_NOT_FOUND);
                });

        log.debug("Staff found: {}", staff.getStaffName());
        return mapToDto(staff);
    }

    @Override
    public UpdateStaffResponseDto updateStaff(Integer staffId, UpdateStaffRequestDto requestDto) {

        log.info("updateStaff() called for staffId: {}", staffId);

        try {

            StaffEntity staff = staffRepo.findById(staffId)
                    .orElseThrow(() -> {
                        log.warn("Staff not found for update with id: {}", staffId);
                        return new StaffException(DATA_NOT_FOUND);
                    });

            log.debug("Updating staff details for: {}", staff.getStaffName());

            staff.setStaffName(requestDto.getStaffName());
            staff.setPhone(requestDto.getPhone());
            staff.setJoiningDate(requestDto.getJoiningDate());

            staffRepo.save(staff);

            log.info("Staff updated successfully with id: {}", staffId);

            return new UpdateStaffResponseDto("Staff updated successfully");

        } catch (DataAccessException dae) {

            log.error("Database error while updating staff with id {}: {}", staffId, dae.getMessage(), dae);
            throw new StaffException(DATA_ACCESS_ERROR,
                    "Something went wrong while updating the staff. Please try again.");
        } catch (StaffException se) {

            throw se;

        } catch (Exception ex) {

            log.error("Unexpected error while updating staff with id {}: {}", staffId, ex.getMessage(), ex);
            throw new StaffException(UNEXPECTED_EXCEPTION, " updating staff");
        }
    }

    private SearchStaffsResponseDto convertToDto(StaffEntity staffEntity){
     return SearchStaffsResponseDto.builder()
                .staffName(staffEntity.getStaffName())
                .staffId(staffEntity.getId())
                .phone(staffEntity.getPhone())
                .joiningDate(staffEntity.getJoiningDate())
                .build();
    }
}
