package com.code.monks.csm.client;
import com.code.monks.csm.dto.email.UserEmailsResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.List;

@Component
public class AuthUserEmailClient {

    private final RestClient restClient;
    private final String emailsUrl;

    public AuthUserEmailClient(
            RestClient.Builder restClientBuilder,
            @Value("${auth.get_user_email.url}") String emailsUrl) {
        this.restClient = restClientBuilder.build();
        this.emailsUrl = emailsUrl;
    }

    public List<String> getAllUserEmails() {
        UserEmailsResponse response = restClient.get()
                .uri(emailsUrl)
                .retrieve()
                .body(UserEmailsResponse.class);

        if (response == null || response.getEmails() == null) {
            throw new IllegalStateException(
                    "Auth API returned no user email list");
        }

        return response.getEmails().stream()
                .filter(email -> email != null && !email.isBlank())
                .map(String::trim)
                .distinct()
                .toList();
    }
}

