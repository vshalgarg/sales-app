package com.code.monks.csm.service;

import com.code.monks.csm.client.AuthRestClient;
import com.code.monks.csm.dto.auth.request.AuthCreateRoleRequestDto;
import com.code.monks.csm.dto.auth.request.AuthUpdateRoleRequestDto;
import com.code.monks.csm.dto.auth.request.CreateRoleRequestDto;
import com.code.monks.csm.dto.auth.response.AuthGetAllRolesDTO;
import com.code.monks.csm.dto.auth.response.AuthGetRoleDetailDto;
import com.code.monks.csm.dto.auth.response.AuthMessageResponseDto;
import com.code.monks.csm.dto.auth.response.MessageResponseDTO;
import com.code.monks.csm.dto.response.GetAllRolesDTO;
import com.code.monks.csm.dto.response.GetRoleDetailDto;
import com.code.monks.csm.dto.response.UpdateRoleRequestDto;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class RoleService {
    private final AuthRestClient authRestClient;
    public MessageResponseDTO createRole(CreateRoleRequestDto requestDto) {
        log.info("Processing add role permissions | roleName={}, roleDesc={}, permissionIds={}",
                requestDto.getRoleName(),
                requestDto.getRoleDesc(),
                requestDto.getPermissionIds());
        AuthCreateRoleRequestDto authRequestDto = new AuthCreateRoleRequestDto(
                requestDto.getRoleName(),
                requestDto.getRoleDesc(),
                requestDto.getPermissionIds(),
                requestDto.getParentRoleId()
        );
        log.info("Calling Auth Service | roleName={} | permissionsCount={}", authRequestDto.getRoleName(),
                authRequestDto.getPermissionIds() != null ? authRequestDto.getPermissionIds().size() : 0);
        AuthMessageResponseDto authResponse = authRestClient.callCreateRole(authRequestDto);
        log.info("Auth Service response received for roleName={}", requestDto.getRoleName());
        return MessageResponseDTO.builder().message(authResponse.getMessage()).build();
    }

    public List<GetAllRolesDTO> getAllRoles() {
        log.info("Fetching all roles from Auth service...");
        List<AuthGetAllRolesDTO> authResponse = authRestClient.callGetAllRoles();
        if (authResponse == null || authResponse.isEmpty()) {
            log.warn("Auth service returned empty/null role list for GetAllRoles");
            return Collections.emptyList();
        }
        log.info("Auth service returned {} roles", authResponse.size());
        List<GetAllRolesDTO> response = authResponse.stream()
                .map(role -> GetAllRolesDTO.builder()
                        .id(role.getId())
                        .roleName(role.getRoleName())
                        .roleDesc(role.getRoleDesc())
                        .build()
                ).collect(Collectors.toList());
        log.info("Successfully mapped {} roles into GetAllRolesDTO", response.size());
        return response;
    }

    public GetRoleDetailDto getRoleDetail(int roleId) {
        log.info("Fetching role detail | roleId={}", roleId);
        log.debug("Calling Auth Service for role detail | roleId={}", roleId);
        AuthGetRoleDetailDto authResponse = authRestClient.callGetRoleDetail(roleId);
        log.debug("Mapping Auth response to DTO | roleId={}", roleId);
        GetRoleDetailDto response = GetRoleDetailDto.builder()
                .roleName(authResponse.getRoleName())
                .roleDesc(authResponse.getRoleDesc())
                .parentRoleId(authResponse.getParentRoleId())
                .parentRoleName(authResponse.getParentRoleName())
                .permissions(authResponse.getPermissions())
                .build();
        log.info("Role detail fetched successfully | roleId={}", roleId);
        return response;
    }

    public MessageResponseDTO updateRole(UpdateRoleRequestDto requestDto, int roleId) {
        log.info("Updating role | roleName={}, roleDesc={}, permissionIds={}", requestDto.getRoleName(), requestDto.getRoleDesc(), requestDto.getPermissionIds());
        AuthUpdateRoleRequestDto authRequestDto =
                new AuthUpdateRoleRequestDto(
                        requestDto.getRoleName(),
                        requestDto.getRoleDesc(),
                        requestDto.getPermissionIds(),
                        requestDto.getParentRoleId()
                );
        log.debug("Prepared AuthUpdateRoleRequestDto: {}", authRequestDto);
        AuthMessageResponseDto response = authRestClient.callUpdateRole(authRequestDto, roleId);
        log.info("Successfully updated role for roleName={} | message={}", requestDto.getRoleName(), response.getMessage());
        return MessageResponseDTO.builder().message(response.getMessage()).build();
    }
}
