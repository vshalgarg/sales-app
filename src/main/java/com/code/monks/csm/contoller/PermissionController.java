package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.response.GetAllPermissionsDto;
import com.code.monks.csm.dto.response.GetPermissionsByRoleTemplateDto;
import com.code.monks.csm.service.AdminService;
import com.code.monks.csm.service.RoleService;
import com.code.monks.csm.validation.HasPermission;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

import static com.code.monks.csm.constants.ApiPaths.PERMISSION.*;

@Slf4j
@RestController
@RequestMapping(PERMISSION_BASE)
@RequiredArgsConstructor
public class PermissionController {

    private final RoleService rollService;
    @HasPermission("PERM_PERMISSION_CRUD")
    @GetMapping(GET_ALL_PERMISSIONS)
    public ResponseEntity<List<GetAllPermissionsDto>> getAllPermissions()
    {
        log.info("API START: Get all permissions request received");
        List<GetAllPermissionsDto> response = rollService.getAllPermissions();
        log.info("API SUCCESS: Permissions fetched successfully | totalPermissions={}", response != null ? response.size() : 0);
        return ResponseEntity.ok(response);
    }

    @HasPermission("PERM_PERMISSION_CRUD")
    @GetMapping(GET_PERMISSIONS_BY_ROLE_TEMPLATE)
    public ResponseEntity<GetPermissionsByRoleTemplateDto> getPermissionsByRoleTemplate(@PathVariable int roleTemplateId)
    {
        log.info("API START: Get permissions by role template request received | roleTemplateId={}", roleTemplateId);
        GetPermissionsByRoleTemplateDto response = rollService.getPermissionsByRoleTemplate(roleTemplateId);
        log.info("API SUCCESS: Permissions fetched successfully for roleTemplateId={}", roleTemplateId);
        return ResponseEntity.ok(response);
    }

}

