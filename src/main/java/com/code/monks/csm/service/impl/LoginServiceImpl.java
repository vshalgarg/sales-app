package com.code.monks.csm.service.impl;

import com.code.monks.csm.client.AuthRestClient;
import com.code.monks.csm.dto.auth.request.AuthLoginRequestDto;
import com.code.monks.csm.dto.auth.response.AuthLoginResponseDto;
import com.code.monks.csm.dto.request.LoginRequestDto;
import com.code.monks.csm.dto.response.LoginResponseDto;
import com.code.monks.csm.service.LoginService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@AllArgsConstructor
public class LoginServiceImpl implements LoginService {

    private final AuthRestClient authRestClient;

    public LoginResponseDto login(LoginRequestDto requestDto) {
        log.info("Initiating login for username: {}", requestDto.getUsername());

        AuthLoginRequestDto authRequestDto = new AuthLoginRequestDto(
                requestDto.getUsername(), requestDto.getPassword()
        );

        AuthLoginResponseDto responseDto = authRestClient.callLogin(authRequestDto);

        log.info("Login successful for userId: {}, username: {}",
                responseDto.getUserId(), responseDto.getUsername());

        return LoginResponseDto.builder()
                .userId(responseDto.getUserId())
                .username(responseDto.getUsername())
                .roles(responseDto.getRoles())
                .token(responseDto.getToken())
                .build();
    }
}
