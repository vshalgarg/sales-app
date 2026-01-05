package com.code.monks.csm.service;

import com.code.monks.csm.dto.request.AddUserRequestDto;
import com.code.monks.csm.dto.request.DeleteUserRequestDto;
import com.code.monks.csm.dto.response.*;

import java.util.List;

public interface UserService {
    AddUserResponseDto addUser(AddUserRequestDto requestDto);
    GetUsersDto getUsers();
    DeleteUserResponseDto deleteUser(Long userId);
    List<SearchUsersResponseDTO> searchUsers(String keyword);
    EncryptedResponseDTO getEncryptedUserDetail(Long userId);
}
