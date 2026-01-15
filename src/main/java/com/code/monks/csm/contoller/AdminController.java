package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.ChangePasswordRequestDTO;
import com.code.monks.csm.service.AdminService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

import static com.code.monks.csm.constants.ApiPaths.BASE;
import static com.code.monks.csm.constants.ApiPaths.CHANGE_PASSWORD;

@RestController
@RequestMapping(BASE)
@Slf4j
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    @PutMapping(CHANGE_PASSWORD)
    public ResponseEntity<Map<String, Object>> changePassword(
            @RequestBody ChangePasswordRequestDTO requestDTO) {

        log.info("Received request to change password for userId: {}",
                requestDTO.getUserId());

        Map<String, Object> response =
                adminService.changePassword(requestDTO);

        return ResponseEntity.ok(response);
    }
}
