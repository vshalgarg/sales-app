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
import com.code.monks.csm.dto.request.SendEmailRequestDTO;
import com.code.monks.csm.dto.response.SendEmailResponseDTO;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
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

    @Value("${auth.change_password.url}")
    private String changePasswordUrl;

    @Value("${auth.send_email.url}")
    private String sendEmailUrl;

    @Value("${auth.role.create.url}")
    private String createRoleUrl;

    @Value("${auth.get.all.roles.url}")
    private String getAllRolesUrl;

    @Value("${auth.role.detail.url}")
    private String roleDetailUrl;

    @Value("${auth.update.role.url}")
    private String updateRoleUrl;

    @Value("${auth.get.all.permissions.url}")
    private String getAllPermissionUrl;

    @Value("${auth.get.role.template.permissions.url}")
    private String getRoleTemplatePermissionsUrl;

    @Value("${auth.get.all.role.template.url}")
    private String getAllRoleTemplateUrl;

    @Value("${auth.delete.role.url}")
    private String deleteRoleUrl;

    @Value("${auth.get.user.role}")
    private String getUserRole;

    @Value("${auth.update.user.roles.url}")
    private String updateUserRolesUrl;

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

    public AuthChangePasswordResponseDTO changePassword(AuthChangePasswordReqDTO authRequestDto) {

        String url = authHost + changePasswordUrl;

        log.info("Calling external auth service at URL: {}", url);

        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);

        log.debug("Request headers prepared: {}", headers.keySet());  // Avoid logging secrets
        log.debug("Sending chnage password request for userId: {}", authRequestDto.getUserId());

        AuthChangePasswordResponseDTO responseDto = genericRestClient.exchange(
                url,
                HttpMethod.PUT,
                authRequestDto,
                headers,
                AuthChangePasswordResponseDTO.class
        );

        log.info("Received response from auth service for userId : {}", authRequestDto.getUserId());

        return responseDto;
    }


    private void updateHeadersForClientNameAndSecret(Map<String,String> headers){
        headers.put("clientName", authClientName);
        headers.put("clientSecret", authClientSecret);
    }

    public SendEmailResponseDTO sendEmail(SendEmailRequestDTO request) {
        String url = authHost + sendEmailUrl;
        log.info("Calling Auth API to send email");
        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        SendEmailResponseDTO response = genericRestClient.exchange(
                url,
                HttpMethod.POST,
                request,
                headers,
                SendEmailResponseDTO.class
        );
        log.info("Auth email API accepted the request");
        return response;
    }
    public AuthMessageResponseDto callCreateRole(AuthCreateRoleRequestDto authRequestDto) {
        String url = authHost + createRoleUrl;
        log.info("Calling external create role API | role: {}", authRequestDto.getRoleName());
        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        AuthMessageResponseDto response = genericRestClient.exchange(url, HttpMethod.POST, authRequestDto, headers, AuthMessageResponseDto.class);
        log.info("Role created successfully | role: {}", authRequestDto.getRoleName());
        return response;
    }

    public List<AuthGetAllRolesDTO> callGetAllRoles() {
        log.info("Calling external callGetAllRoles API");
        String url = authHost + getAllRolesUrl;
        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        AuthGetAllRolesDTO[] responseArray = genericRestClient.exchange(url, HttpMethod.GET, null, headers, AuthGetAllRolesDTO[].class);
        return Arrays.asList(responseArray);
    }

    public AuthGetRoleDetailDto callGetRoleDetail(int roleId) {
        String url = UriComponentsBuilder
                .fromUriString(authHost + roleDetailUrl)
                .buildAndExpand(roleId)
                .toUriString();
        log.debug("Calling Auth API: Get Role Detail | roleId={}, url={}", roleId, url);
        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        AuthGetRoleDetailDto authResponse = genericRestClient.exchange(url, HttpMethod.GET, null, headers, AuthGetRoleDetailDto.class);
        log.info("Auth API returned role detail successfully | roleId={}", roleId);
        return authResponse;
    }

    public AuthMessageResponseDto callUpdateRole(AuthUpdateRoleRequestDto authRequestDto, int roleId){
        log.info("Calling external callUpdateRole API | role: {}", authRequestDto.getRoleName());
        String url = UriComponentsBuilder
                .fromUriString(authHost + updateRoleUrl)
                .buildAndExpand(roleId)
                .toUriString();
        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        AuthMessageResponseDto response = genericRestClient.exchange(url, HttpMethod.PUT, authRequestDto, headers, AuthMessageResponseDto.class);
        log.info("Update Role successfully | role : {}", authRequestDto.getRoleName());
        return response;
    }

    public List<AuthGetAllPermissionsDto> callGetAllPermissions() {
        String url = authHost + getAllPermissionUrl;
        log.info("Calling Auth API: Get All Permissions | url={}", url);
        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        AuthGetAllPermissionsDto[] arrayResponse = genericRestClient.exchange(url, HttpMethod.GET, null, headers, AuthGetAllPermissionsDto[].class);
        return Arrays.asList(arrayResponse);
    }

    public AuthGetPermissionsByRoleTemplateDto callGetPermissionsByRoleTemplate(int roleTemplateId){
        log.info("Calling external getPermissionsByRole API | roleTemplateId: {}", roleTemplateId);
        String url = UriComponentsBuilder
                .fromUriString(authHost + getRoleTemplatePermissionsUrl)
                .buildAndExpand(roleTemplateId)
                .toUriString();
        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        AuthGetPermissionsByRoleTemplateDto response = genericRestClient.exchange(url, HttpMethod.GET, null, headers, AuthGetPermissionsByRoleTemplateDto.class);
        log.info("Get Role_Permissions successfully | roleTemplateId : {}", roleTemplateId);
        return response;
    }

    public List<AuthRoleTemplateDto> callGetAllRoleTemplate() {
        String url = authHost + getAllRoleTemplateUrl;
        log.debug("Calling Auth API: Get All Role Template | url={}", url);
        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        AuthRoleTemplateDto[] arrayResponse = genericRestClient.exchange(
                url,
                HttpMethod.GET,
                null,
                headers,
                AuthRoleTemplateDto[].class
        );
        return Arrays.asList(arrayResponse);
    }

    public AuthMessageResponseDto callDeleteRole(int roleId) {
        String url = UriComponentsBuilder
                .fromUriString(authHost + deleteRoleUrl)
                .buildAndExpand(roleId)
                .toUriString();
        log.debug("Calling Auth API DELETE Role | roleId={}, url={}", roleId, url);
        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        AuthMessageResponseDto authResponse = genericRestClient.exchange(
                url,
                HttpMethod.DELETE,
                null,
                headers,
                AuthMessageResponseDto.class
        );
        log.info("Auth API DELETE Role response received | roleId={}, message={}", roleId, authResponse.getMessage());
        return authResponse;
    }

    public AuthGetUserRoleDto getUserRoleDetail(Long userId) {
        String url = UriComponentsBuilder
                .fromUriString(authHost + getUserRole)
                .buildAndExpand(userId)
                .toUriString();
        log.info("Calling Auth API to get user roles | userId={}", userId);
        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        AuthGetUserRoleDto response = genericRestClient.exchange(
                url,
                HttpMethod.GET,
                null,
                headers,
                AuthGetUserRoleDto.class
        );
        log.info("Received user role details from Auth | userId={}", userId);
        return response;
    }
    public AuthUpdateUserRolesResponseDto callUpdateUserRoles(Long userId, AuthUpdateUserRolesRequestDto requestDto) {
        String url = UriComponentsBuilder
                .fromUriString(authHost + updateUserRolesUrl)
                .buildAndExpand(userId)
                .toUriString();
        log.info("Calling Auth API to update user roles | userId={}", userId);
        Map<String, String> headers = new HashMap<>();
        updateHeadersForClientNameAndSecret(headers);
        AuthUpdateUserRolesResponseDto response = genericRestClient.exchange(
                        url,
                        HttpMethod.PUT,
                        requestDto,
                        headers,
                        AuthUpdateUserRolesResponseDto.class
                );
        log.info("Auth API role update response received | userId={}", userId);
        return response;
    }
}
