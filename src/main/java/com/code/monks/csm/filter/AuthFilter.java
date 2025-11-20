package com.code.monks.csm.filter;

import com.code.monks.csm.client.AuthRestClient;
import com.code.monks.csm.context.RequestContext;
import com.code.monks.csm.dto.User;
import com.code.monks.csm.dto.auth.request.AuthTokenValidateRequestDto;
import com.code.monks.csm.exception.ExternalServiceException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.Objects;
import java.util.Set;

@Component
@AllArgsConstructor
@Slf4j
public class AuthFilter extends OncePerRequestFilter {

    private final AuthRestClient restClient;
    private final Environment environment;

    private static final String BEARER_PREFIX = "Bearer";
    private static final String PATH = "/csm/api/v1/login";
    private static final long DUMMY_USER_ID = 101L;

    private final AuthRestClient authRestClient;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request){
       final String path = request.getRequestURI();
       return Objects.equals(PATH,path);
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        try {
            if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
                log.debug("Skipping auth for OPTIONS request");
                filterChain.doFilter(request, response);
                return;
            }

            String authHeader = request.getHeader("Authorization");

            log.debug("Authorization header received: {}", authHeader);

            if (authHeader != null && authHeader.startsWith(BEARER_PREFIX)) {
                handleBearerToken(authHeader);
            } else if (isLocalProfileActive()) {
                log.info("Local profile active: using dummy user");
                handleLocalProfile();
            } else {
                log.warn("Authorization header missing or invalid");
                respondUnauthorized(response, "Missing or invalid Authorization header");
                return;
            }

            validateContextUser();
            filterChain.doFilter(request, response);
            log.debug("Authentication passed. Request forwarded");

        } catch (AuthenticationException e) {
            log.error("Authentication exception: {}", e.getMessage(), e);
            respondUnauthorized(response, e.getMessage());
        } catch (Exception ex) {
            log.error("Unhandled exception during authentication filter: {}", ex.getMessage(), ex);
            respondUnauthorized(response, "Internal authentication error");
        }
    }

    private void handleBearerToken(String authHeader) throws AuthenticationException {
        String token = authHeader.substring(BEARER_PREFIX.length());
        System.out.println(token);
        log.debug("Processing Bearer token");

        try {
            AuthTokenValidateRequestDto requestDto = new AuthTokenValidateRequestDto();
            requestDto.setJwtToken(token);

            User user = restClient.validateToken(requestDto);
            log.info("Authenticated user ID: {}, roles: {}", user.getUserId(), user.getRoles());

            RequestContext.setUser(user);

            User contextUser  = RequestContext.getUser();
            if (contextUser == null || !contextUser.getUserId().equals(user.getUserId())) {
                log.error("Context user mismatch! Expected: {}, Actual: {}",
                        user.getUserId(),
                        contextUser != null ? contextUser.getUserId() : "null");
                throw new AuthenticationException("Authentication context error");
            }

        } catch (ExternalServiceException e) {
            log.error("Token validation failed", e);
            throw new AuthenticationException("Token validation failed");
        }
    }

    private void handleLocalProfile() {
        log.warn("Using local profile - ONLY FOR DEVELOPMENT!");
        User dummyUser = createDummyUser();
        RequestContext.setUser(dummyUser);
        log.info("Set dummy user with ID: {}", dummyUser.getUserId());
    }

    private void validateContextUser() throws AuthenticationException {
        User contextUser = RequestContext.getUser();
        if (contextUser == null || contextUser.getUserId() == null) {
            log.error("No valid user in context after authentication");
            throw new AuthenticationException("Authentication context error");
        }
        log.debug("Validated context user: {}", contextUser.getUserId());
    }

    private boolean isLocalProfileActive() {
        return Arrays.stream(environment.getActiveProfiles())
                .anyMatch("local"::equalsIgnoreCase);
    }

    private User createDummyUser() {
        User dummy = new User();
        dummy.setUserId(DUMMY_USER_ID);
        dummy.setUsername("dummy@local.test");
        dummy.setRoles(Set.of("ROLE_AGENT"));
        return dummy;
    }

    private void respondUnauthorized(HttpServletResponse response, String message) throws IOException {
        log.warn("Responding with unauthorized: {}", message);
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json");
        response.getWriter().write(String.format("{\"error\": \"%s\"}", message));
    }

    private static class AuthenticationException extends Exception {
        public AuthenticationException(String message) {
            super(message);
        }
    }

}
