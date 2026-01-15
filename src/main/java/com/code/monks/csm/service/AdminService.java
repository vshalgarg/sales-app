package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.ChangePasswordRequestDTO;

import java.util.Map;

public interface AdminService {

    Map<String,Object> changePassword(ChangePasswordRequestDTO requestDTO);
}
