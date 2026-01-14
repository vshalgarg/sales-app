package com.code.monks.csm.service.impl;

import com.code.monks.csm.client.AuthRestClient;
import com.code.monks.csm.dto.auth.request.AuthChangePasswordReqDTO;
import com.code.monks.csm.dto.auth.response.AuthChangePasswordResponseDTO;
import com.code.monks.csm.dto.request.ChangePasswordRequestDTO;
import com.code.monks.csm.dto.response.LoginResponseDto;
import com.code.monks.csm.service.AdminService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class AdminServiceImpl implements AdminService {

    private final AuthRestClient authRestClient;
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
}
