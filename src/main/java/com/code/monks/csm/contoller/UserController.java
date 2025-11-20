package com.code.monks.csm.contoller;

import com.code.monks.csm.dto.request.AddUserRequestDto;
import com.code.monks.csm.dto.request.DeleteUserRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.service.UserService;
import jakarta.validation.Valid;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import static com.code.monks.csm.constants.ApiPaths.*;

@RequestMapping(BASE)
@RestController
@AllArgsConstructor
@Slf4j
public class UserController {

    private final UserService userService;

    @PostMapping(ADD_USER)
    public ResponseEntity<AddUserResponseDto> addUser(@Valid @RequestBody AddUserRequestDto requestDto) {
        log.info("ADD_USER API called with username: {}", requestDto.getUsername());

        AddUserResponseDto responseDto = userService.addUser(requestDto);

        log.info("ADD_USER API completed for username: {} with status: {}",
                requestDto.getUsername(), responseDto.getStatus());

        return ResponseEntity.ok(responseDto);
    }

    @GetMapping(GET_USERS)
    public ResponseEntity<GetUsersDto> getUsers() {
        log.info("GET_USERS API called");

        GetUsersDto users = userService.getUsers();

        log.info("GET_USERS API returned {} users",
                (users != null && users.getUsers() != null) ? users.getUsers().size() : 0);

        return ResponseEntity.ok(users);
    }

    @PostMapping(DELETE_USER)
    public ResponseEntity<DeleteUserResponseDto> deleteUser(@Valid @RequestBody DeleteUserRequestDto requestDto) {
        log.info("DELETE_USER API called for userId: {}, username: {}", requestDto.getUserId(), requestDto.getUsername());

        DeleteUserResponseDto responseDto = userService.deleteUser(requestDto);

        log.info("DELETE_USER API completed for userId: {}",
                requestDto.getUserId());

        return ResponseEntity.ok(responseDto);
    }

    @GetMapping(SEARCH_USER)
    public ResponseEntity<List<SearchUsersResponseDTO>> searchUsers(@RequestParam String keyword) {
        List<SearchUsersResponseDTO> response = userService.searchUsers(keyword);
        return ResponseEntity.ok(response);
    }

    @GetMapping(GET_ENCRYPTED_USER_DETAIL)
    public ResponseEntity<EncryptedResponseDTO> getEncryptedUserDetail(@PathVariable Long userId){
        return ResponseEntity.ok(userService.getEncryptedUserDetail(userId));
    }

}
