package com.code.monks.csm.dto.email;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
@AllArgsConstructor
@Getter
@Setter
public class UserEmailsResponse {

    private List<String> emails;

}

