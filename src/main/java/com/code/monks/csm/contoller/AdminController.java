package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.ApiResponse;
import com.code.monks.csm.dto.request.ChangePasswordRequestDTO;
import com.code.monks.csm.dto.request.ConfigurationRequestDto;
import com.code.monks.csm.dto.response.ConfigurationResponseDto;
import com.code.monks.csm.service.AdminService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

import static com.code.monks.csm.constants.ApiPaths.*;

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


    @GetMapping(GET_CONFIGURATIONS)
    public ResponseEntity<ApiResponse<List<ConfigurationResponseDto>>> getConfigurations() {
        List<ConfigurationResponseDto> configurations = adminService.getConfigurations();
        return ResponseEntity.ok(
                ApiResponse.success(
                        "Configurations fetched successfully",
                        configurations
                )
        );
    }

    @PatchMapping(UPDATE_CONFIGURATION)
    public ResponseEntity<ApiResponse<Void>> updateConfiguration(
            @PathVariable Integer configurationId,
            @RequestBody @Valid ConfigurationRequestDto requestDto) {

        log.info("Received request to update configuration id: {}", configurationId);
        adminService.updateConfiguration(configurationId, requestDto);

        return ResponseEntity.ok(
                ApiResponse.success("Configuration updated successfully")
        );
    }

}
