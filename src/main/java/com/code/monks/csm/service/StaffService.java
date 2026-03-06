package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.AddStaffRequestDto;
import com.code.monks.csm.dto.request.DeleteStaffRequestDto;
import com.code.monks.csm.dto.request.UpdateStaffRequestDto;
import com.code.monks.csm.dto.response.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface StaffService {
    AddStaffResponseDto addStaff(AddStaffRequestDto requestDto);
    PagedResponseDto<GetStaffDto> getStaff(int page, int size);
    DeleteStaffResponseDto deleteStaff(DeleteStaffRequestDto requestDto);
    PagedResponseDto<SearchStaffsResponseDto> searchStaffs(String keyword, Pageable pageable);
    List<GetStaffDto> getAllActiveStaff();
    GetStaffDto getStaffById(Integer staffId);

    UpdateStaffResponseDto updateStaff(Integer staffId, UpdateStaffRequestDto requestDto);
}
