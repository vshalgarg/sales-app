package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.LoginRequestDto;
import com.code.monks.csm.dto.response.LoginResponseDto;

public interface LoginService {
    LoginResponseDto login (LoginRequestDto requestDto);
}
