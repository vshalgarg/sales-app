package com.code.monks.csm.service.impl;

import com.code.monks.csm.client.AuthRestClient;
import com.code.monks.csm.dto.auth.request.AuthAddUserRequestDto;
import com.code.monks.csm.dto.auth.request.AuthDeleteUserRequestDto;
import com.code.monks.csm.dto.auth.response.*;
import com.code.monks.csm.dto.request.AddUserRequestDto;
import com.code.monks.csm.dto.request.DeleteUserRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserServiceImpl implements UserService {

    private final AuthRestClient authRestClient;

    @Override
    public AddUserResponseDto addUser(AddUserRequestDto requestDto) {
        log.info("addUser() called with username: {} and roles: {}",
                requestDto.getUsername(), requestDto.getRoles());

        AuthAddUserRequestDto authRequestDto = new AuthAddUserRequestDto(
                requestDto.getUsername(), requestDto.getPassword(), requestDto.getRoles()
        );
        log.debug("Calling authRestClient.callAddUser() with AuthAddUserRequestDto: {}", authRequestDto);

        AuthAddUserResponseDto authResponseDto = authRestClient.callAddUser(authRequestDto);
        log.info("Received response from auth service with status: {}", authResponseDto.getStatus());

        return AddUserResponseDto.builder()
                .status(authResponseDto.getStatus())
                .build();
    }

    @Override
    public GetUsersDto getUsers() {
        log.info("getUsers() called");

        AuthGetUsersDto authGetUsersDto = authRestClient.callGetUsers();
        log.info("Received {} users from auth service",
                (authGetUsersDto.getUsers() != null ? authGetUsersDto.getUsers().size() : 0));

        return GetUsersDto.builder()
                .users(authGetUsersDto.getUsers())
                .build();
    }

    @Override
    public DeleteUserResponseDto deleteUser(Long userId) {
        log.info("deleteUser() called for userId: {}", userId);

        AuthDeleteUserResponseDto authResponse =
                authRestClient.callDeleteUser(userId);
        log.info("Received response from auth service: {}",
                authResponse.getMessage());

        return DeleteUserResponseDto.builder()
                .message(authResponse.getMessage())
                .build();
    }

    public List<SearchUsersResponseDTO> searchUsers(String keyword) {
        // Step 1: Call Auth Service
        AuthSearchUsersResponseDto authResponse = authRestClient.callSearchUsers(keyword);

        // Step 2: Convert List<UserInfoDTO> → List<SearchUsersResponseDTO>
        List<SearchUsersResponseDTO> users = authResponse.getUsersInfo().stream()
                .map(userInfo -> SearchUsersResponseDTO.builder()
                        .id(userInfo.getId())
                        .username(userInfo.getUsername())
                        .build())
                .toList();

        // Step 3: Return to controller
        return users;
    }

    public EncryptedResponseDTO getEncryptedUserDetail(Long userId){
        AuthEncryptedUserDetailDTO authResponseDto = authRestClient.callGetUserDetail(userId);
        return EncryptedResponseDTO.builder().encryptedPayload(authResponseDto.getEncryptedPayload()).build();
    }

}
