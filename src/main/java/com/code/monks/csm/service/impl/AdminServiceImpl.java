package com.code.monks.csm.service.impl;

import com.code.monks.csm.client.AuthRestClient;
import com.code.monks.csm.dto.auth.request.AuthChangePasswordReqDTO;
import com.code.monks.csm.dto.auth.response.AuthChangePasswordResponseDTO;
import com.code.monks.csm.dto.request.ChangePasswordRequestDTO;
import com.code.monks.csm.dto.request.ConfigurationRequestDto;
import com.code.monks.csm.dto.response.ConfigurationResponseDto;
import com.code.monks.csm.entity.ConfigurationEntity;
import com.code.monks.csm.enums.ResponseErrorCode;
import com.code.monks.csm.exception.BusinessException;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.repository.ConfigurationRepository;
import com.code.monks.csm.service.AdminService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

import static com.code.monks.csm.enums.ResponseErrorCode.CONFIGURATION_NOT_FOUND;
import static com.code.monks.csm.enums.ResponseErrorCode.DUPLICATE_CONFIGURATION_KEY;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminServiceImpl implements AdminService {

    private final AuthRestClient authRestClient;
    private final ConfigurationRepository configurationRepository;

    @Override
    public Map<String, Object> changePassword(ChangePasswordRequestDTO requestDTO) {
        log.info("Starting change password for userId: {}", requestDTO.getUserId());

        AuthChangePasswordReqDTO authChangePasswordReqDTO = new AuthChangePasswordReqDTO(
                requestDTO.getUserId(),
                requestDTO.getNewPassword()
        );

        AuthChangePasswordResponseDTO authResponse = authRestClient.changePassword(authChangePasswordReqDTO);

        log.info("Change password successful for userId: {}", requestDTO.getUserId());

        return Map.of(
                "message", authResponse.getMessage(),
                "userId", requestDTO.getUserId(),
                "status", "SUCCESS"
        );
    }

    @Override
    public void addConfiguration(ConfigurationRequestDto requestDto) {

        log.info("Adding configuration with key: {}", requestDto.key());
        if (configurationRepository.existsByKey(requestDto.key())) {
            throw new BusinessException(DUPLICATE_CONFIGURATION_KEY);
        }
        ConfigurationEntity configuration = ConfigurationEntity.builder()
                .key(requestDto.key())
                .value(requestDto.value())
                .description(requestDto.description())
                .build();

        configurationRepository.save(configuration);
        log.info("Configuration added successfully with key: {}", requestDto.key());
    }

    @Override
    public List<ConfigurationResponseDto> getConfigurations() {

        log.info("Fetching all configurations");
        List<ConfigurationResponseDto> configurations =
                configurationRepository.findAll()
                        .stream()
                        .map(this::mapConfiguration)
                        .toList();
        log.info("Fetched {} configurations", configurations.size());
        return configurations;
    }

    @Override
    public void updateConfiguration(Integer configurationId, ConfigurationRequestDto requestDto) {

        log.info("Updating configuration id: {}", configurationId);
        ConfigurationEntity configuration =
                configurationRepository.findById(configurationId)
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        CONFIGURATION_NOT_FOUND,
                                        " with id: " + configurationId));

        configuration.setKey(requestDto.key());
        configuration.setValue(requestDto.value());
        configuration.setDescription(requestDto.description());
        configurationRepository.save(configuration);
        log.info("Configuration updated successfully for id: {}", configurationId);
    }

    @Override
    public void deleteConfiguration(Integer configurationId) {

        log.info("Deleting configuration id: {}", configurationId);

        ConfigurationEntity configuration =
                configurationRepository.findById(configurationId)
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        CONFIGURATION_NOT_FOUND,
                                        " with id: " + configurationId));

        configurationRepository.delete(configuration);
        log.info("Configuration deleted successfully for id: {}",
                configurationId);
    }

    private ConfigurationResponseDto mapConfiguration(
            ConfigurationEntity configuration) {

        return ConfigurationResponseDto.builder()
                .id(configuration.getId())
                .key(configuration.getKey())
                .value(configuration.getValue())
                .description(configuration.getDescription())
                .build();
    }
}
