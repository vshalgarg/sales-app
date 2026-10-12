package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.auth.request.CreateRoleRequestDto;
import com.code.monks.csm.dto.auth.response.MessageResponseDTO;
import com.code.monks.csm.dto.response.GetAllRolesDTO;
import com.code.monks.csm.dto.response.GetRoleDetailDto;
import com.code.monks.csm.dto.response.UpdateRoleRequestDto;
import com.code.monks.csm.service.RoleService;
import com.code.monks.csm.validation.HasPermission;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.code.monks.csm.constants.ApiPaths.BASE;
import static com.code.monks.csm.constants.ApiPaths.ROLE.*;

@Slf4j
@RequiredArgsConstructor
@RequestMapping(ROLE_BASE)
@RestController
public class RoleController {
    private final RoleService rollService;
    @PostMapping(CREATE_ROLE)
    public ResponseEntity<MessageResponseDTO> createRole(@Valid @RequestBody CreateRoleRequestDto requestDto) {
        log.info("API START: Create role request received");
        log.info("Creating role | roleName={} | permissionCount={} | permissionIds={}",
                requestDto.getRoleName(),
                requestDto.getPermissionIds() != null ? requestDto.getPermissionIds().size() : 0,
                requestDto.getPermissionIds());
        MessageResponseDTO response = rollService.createRole(requestDto);
        log.info("API SUCCESS: Role created successfully | roleName={}", requestDto.getRoleName());
        return ResponseEntity.ok(response);
    }

    @HasPermission("PERM_ROLE_CRUD")
    @GetMapping(GET_ALL_ROLES)
    public ResponseEntity<List<GetAllRolesDTO>> getAllRoles()
    {
        log.info("API START: Get all roles request received");
        List<GetAllRolesDTO> response = rollService.getAllRoles();
        log.info("API SUCCESS: Roles fetched successfully | totalRoles={}", response != null ? response.size() : 0);
        return ResponseEntity.ok(response);
    }

    @HasPermission("PERM_ROLE_CRUD")
    @GetMapping(GET_ROLE_DETAIL)
    public ResponseEntity<GetRoleDetailDto> getRoleDetail(@PathVariable int roleId) {
        log.info("API START: Get role detail request received | roleId={}", roleId);
        GetRoleDetailDto response = rollService.getRoleDetail(roleId);
        log.info("API SUCCESS: Role detail fetched successfully | roleId={}", roleId);
        return ResponseEntity.ok(response);
    }

    @HasPermission("PERM_ROLE_CRUD")
    @PutMapping(UPDATE_ROLE)
    public ResponseEntity<MessageResponseDTO> updateRole(@PathVariable int roleId, @Valid @RequestBody UpdateRoleRequestDto requestDto) {
        log.info("API START: Update role request received");
        log.info("Updating role | roleId={} | roleName={} | permissionCount={} | permissionIds={}",
                roleId,
                requestDto.getRoleName(),
                requestDto.getPermissionIds() != null ? requestDto.getPermissionIds().size() : 0,
                requestDto.getPermissionIds());
        MessageResponseDTO response = rollService.updateRole(requestDto, roleId);
        log.info("API SUCCESS: Role updated successfully | roleId={} | roleName={}", roleId, requestDto.getRoleName());
        return ResponseEntity.ok(response);
    }
}
