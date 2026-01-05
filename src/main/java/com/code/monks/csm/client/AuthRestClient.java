package com.code.monks.csm.client;

import com.code.monks.csm.dto.User;
import com.code.monks.csm.dto.auth.request.*;
import com.code.monks.csm.dto.auth.response.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Component;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class AuthRestClient {

    @Value("${auth.host}")
    private String authHost;

    @Value("${auth.get_user_detail.url}")
    private String getUserDetailUrl;

    @Value("${auth.register.url}")
    private String registerUrl;

    @Value("${auth.login.url}")
    private String loginUrl;

    @Value("${auth.getUsers.url}")
    private String getUsersUrl;

    @Value("${auth.deleteUser.url}")
    private String deleteUserUrl;

    @Value("${auth.searchUsers.url}")
    private String searchUsersUrl;

    @Value("${auth.validateToken.url}")
    private String validateTokenUrl;

    @Value("${auth.client.name}")
    private String authClientName;

    @Value("${auth.client.secret}")
    private String authClientSecret;

    private final GenericRestClient genericRestClient;

    public AuthLoginResponseDto callLogin(AuthLoginRequestDto authRequestDto) {
        String url = authHost + loginUrl;

        log.info("Calling external auth service at URL: {}", url);

        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);

        log.debug("Request headers prepared: {}", headers.keySet());  // Avoid logging secrets
        log.debug("Sending login request for username: {}", authRequestDto.getUsername());

        AuthLoginResponseDto responseDto = genericRestClient.exchange(
                url,
                HttpMethod.POST,
                authRequestDto,
                headers,
                AuthLoginResponseDto.class
        );

        log.info("Received response from auth service for username: {}", responseDto.getUsername());

        return responseDto;
    }

    public AuthAddUserResponseDto callAddUser(AuthAddUserRequestDto authRequestDto) {
        String url = authHost + registerUrl;
        log.info("Calling Auth Service ADD_USER endpoint: {}", url);

        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        log.debug("Headers for ADD_USER request: {}", headers.keySet()); // avoid logging secrets
        log.debug("Request payload for ADD_USER: {}", authRequestDto);

        AuthAddUserResponseDto responseDto = genericRestClient.exchange(
                url, HttpMethod.POST, authRequestDto, headers, AuthAddUserResponseDto.class
        );

        log.info("Received response from Auth Service ADD_USER with status: {}", responseDto.getStatus());
        return responseDto;
    }

    public AuthGetUsersDto callGetUsers() {
        String url = authHost + getUsersUrl;
        log.info("Calling Auth Service GET_USERS endpoint: {}", url);

        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        log.debug("Headers for GET_USERS request: {}", headers.keySet());

        AuthGetUsersDto authGetUsersDto = genericRestClient.exchange(
                url, HttpMethod.GET, null, headers, AuthGetUsersDto.class
        );

        log.info("Received {} users from Auth Service GET_USERS",
                (authGetUsersDto.getUsers() != null ? authGetUsersDto.getUsers().size() : 0));
        return authGetUsersDto;
    }

    public AuthDeleteUserResponseDto callDeleteUser(Long userId) {
        String url = authHost + deleteUserUrl;
        log.info("Calling Auth Service DELETE_USER endpoint: {}", url);

        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        log.debug("Headers for DELETE_USER request: {}", headers.keySet());

        Map<String, Object> uriVariables = new HashMap<>();
        uriVariables.put("userId", userId);

        return genericRestClient.exchange(
                url,
                HttpMethod.POST,
                null,
                headers,
                AuthDeleteUserResponseDto.class,
                uriVariables
        );
    }

    public AuthSearchUsersResponseDto callSearchUsers(String searchKeyword) {
        String url = UriComponentsBuilder
                .fromHttpUrl(authHost + searchUsersUrl)
                .queryParam("keyword", searchKeyword)
                .toUriString();
        log.info("Calling Auth Service SEARCH_USERS endpoint: {}", url);

        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);

        return genericRestClient.exchange(
                url,
                HttpMethod.GET,
                null,
                headers,
                AuthSearchUsersResponseDto.class
        );
    }

    public AuthEncryptedUserDetailDTO callGetUserDetail(Long userId) {
        String url = UriComponentsBuilder
                .fromHttpUrl(authHost + getUserDetailUrl + "/{userId}")
                .buildAndExpand(userId) // replaces {userId} in path
                .toUriString();

        log.info("Calling Auth Service SEARCH_USERS endpoint: {}", url);

        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);

        return genericRestClient.exchange(
                url,
                HttpMethod.GET,
                null,
                headers,
                AuthEncryptedUserDetailDTO.class
        );
    }

    public User validateToken(AuthTokenValidateRequestDto authRequestDto){
        String url = authHost + validateTokenUrl;
        Map<String,String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        AuthTokenValidateResponseDto response = genericRestClient.exchange(url, HttpMethod.POST,
                authRequestDto, headers, AuthTokenValidateResponseDto.class);

        User user = new User();
        user.setUserId(response.getUserId());
        user.setUsername(response.getUsername());
        user.setRoles(response.getRoles());
        return user;
    }

    private void updateHeadersForClientNameAndSecret(Map<String,String> headers){
        headers.put("clientName", authClientName);
        headers.put("clientSecret", authClientSecret);
    }

}
