package com.code.monks.csm.dto.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
@Builder
public class GetUsersDto {
    public List<Map<String,Object>> users;
}
