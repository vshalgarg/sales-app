package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.AddStaffRequestDto;
import com.code.monks.csm.dto.request.DeleteStaffRequestDto;
import com.code.monks.csm.dto.response.*;

import java.util.List;

public interface StaffService {
    AddStaffResponseDto addStaff(AddStaffRequestDto requestDto);
    PagedResponseDto<GetStaffDto> getStaff(int page, int size);
    DeleteStaffResponseDto deleteStaff(DeleteStaffRequestDto requestDto);
    List<SearchStaffsResponseDto> searchStaffs(String keyword);
}
