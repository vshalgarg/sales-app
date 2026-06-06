package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.ChangePasswordRequestDTO;
import com.code.monks.csm.dto.request.ConfigurationRequestDto;
import com.code.monks.csm.dto.response.ConfigurationResponseDto;

import java.util.List;
import java.util.Map;

public interface AdminService {

    Map<String,Object> changePassword(ChangePasswordRequestDTO requestDTO);
    void addConfiguration(ConfigurationRequestDto requestDto);
    List<ConfigurationResponseDto> getConfigurations();
    void updateConfiguration(
            Integer configurationId,
            ConfigurationRequestDto requestDto);
    void deleteConfiguration(Integer configurationId);
}
