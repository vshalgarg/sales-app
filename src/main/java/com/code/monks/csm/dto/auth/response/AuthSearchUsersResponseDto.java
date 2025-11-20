package com.code.monks.csm.dto.auth.response;

import com.code.monks.csm.dto.response.UserInfoDTO;
import lombok.Data;

import java.util.List;

@Data
public class AuthSearchUsersResponseDto {
    private List<UserInfoDTO> usersInfo;
}
