package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.LoginRequestDto;
import com.code.monks.csm.dto.response.LoginResponseDto;
import com.code.monks.csm.service.LoginService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import static com.code.monks.csm.constants.ApiPaths.BASE;
import static com.code.monks.csm.constants.ApiPaths.LOGIN;

@Slf4j
@RequestMapping(BASE)
@RestController
@AllArgsConstructor
public class LoginController {

    private final LoginService loginService;

    @PostMapping(LOGIN)
    public ResponseEntity<LoginResponseDto> login(@Valid @RequestBody LoginRequestDto requestDto) {
        log.info("Login request received for username: {}", requestDto.getUsername());

        LoginResponseDto response = loginService.login(requestDto);

        log.info("Login successful for username: {}", requestDto.getUsername());
        return ResponseEntity.ok(response);
    }
}
