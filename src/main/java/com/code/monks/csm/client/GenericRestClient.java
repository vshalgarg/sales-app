package com.code.monks.csm.client;

import com.code.monks.csm.exception.ExternalServiceException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.util.Collections;
import java.util.Map;

import static com.code.monks.csm.enums.ResponseErrorCode.EXTERNAL_API_CALL_FAILED;
import static com.code.monks.csm.enums.ResponseErrorCode.EXTERNAL_SERVICE_ERROR;

@Component
@Slf4j
public class GenericRestClient {

    private final RestTemplate restTemplate;

    public GenericRestClient(RestTemplate restTemplate) {
        this.restTemplate = restTemplate;
    }

    public <T, R> R exchange(String url, HttpMethod method, T requestBody, Map<String, String> headers, Class<R> responseType) {
        try {
            HttpHeaders reqHeaders = new HttpHeaders();

            // Only set Content-Type for non-GET requests
            if (method != HttpMethod.GET) {
                reqHeaders.setContentType(MediaType.APPLICATION_JSON);
            }

            // Always set Accept
            reqHeaders.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));

            // Add custom headers
            if (!CollectionUtils.isEmpty(headers)) {
                headers.forEach(reqHeaders::add);
            }

            // Prepare HttpEntity
            HttpEntity<?> requestEntity = (method == HttpMethod.GET)
                    ? new HttpEntity<>(reqHeaders)       // GET has no body
                    : new HttpEntity<>(requestBody, reqHeaders);  // POST/PUT/DELETE with body

            // Execute request
            ResponseEntity<String> response = restTemplate.exchange(url, method, requestEntity, String.class);

            String responseBody = response.getBody();
            if (responseBody == null || responseBody.trim().isEmpty()) {
                log.warn("Empty response from external service: {}", url);
                throw new ExternalServiceException(EXTERNAL_SERVICE_ERROR, "Empty response body");
            }

            ObjectMapper mapper = new ObjectMapper();
            JsonNode node = mapper.readTree(responseBody);

            // Check for error response
            if (node.has("responseCode") && node.has("message") && node.size() == 2) {
                String errorCode = node.get("responseCode").asText();
                String message = node.get("message").asText();
                log.error("Received error from {} | code: {} | message: {}", url, errorCode, message);
                throw new ExternalServiceException(EXTERNAL_SERVICE_ERROR, errorCode + "::" + message);
            }

            return mapper.readValue(responseBody, responseType);

        } catch (JsonProcessingException e) {
            log.error("Failed to parse response from {}: {}", url, e.getMessage());
            throw new ExternalServiceException(EXTERNAL_SERVICE_ERROR, "Failed to parse response");
        } catch (RestClientException ex) {
            log.error("Error calling external API: {} - {}", url, ex.getMessage(), ex);
            throw new ExternalServiceException(EXTERNAL_API_CALL_FAILED, "RestClientException");
        }
    }

    public <T, R> R exchange(
            String url,
            HttpMethod method,
            T requestBody,
            Map<String, String> headers,
            Class<R> responseType,
            Map<String, ?> uriVariables
    ) {
        try {
            HttpHeaders reqHeaders = new HttpHeaders();

            if (method != HttpMethod.GET) {
                reqHeaders.setContentType(MediaType.APPLICATION_JSON);
            }

            reqHeaders.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));

            if (!CollectionUtils.isEmpty(headers)) {
                headers.forEach(reqHeaders::add);
            }

            HttpEntity<?> requestEntity = (method == HttpMethod.GET)
                    ? new HttpEntity<>(reqHeaders)
                    : new HttpEntity<>(requestBody, reqHeaders);

            ResponseEntity<String> response;

            if (uriVariables != null && !uriVariables.isEmpty()) {
                response = restTemplate.exchange(
                        url,
                        method,
                        requestEntity,
                        String.class,
                        uriVariables
                );
            } else {
                response = restTemplate.exchange(
                        url,
                        method,
                        requestEntity,
                        String.class
                );
            }

            String responseBody = response.getBody();
            if (responseBody == null || responseBody.trim().isEmpty()) {
                throw new ExternalServiceException(EXTERNAL_SERVICE_ERROR, "Empty response body");
            }

            ObjectMapper mapper = new ObjectMapper();
            JsonNode node = mapper.readTree(responseBody);

            if (node.has("responseCode") && node.has("message") && node.size() == 2) {
                throw new ExternalServiceException(
                        EXTERNAL_SERVICE_ERROR,
                        node.get("responseCode").asText() + "::" + node.get("message").asText()
                );
            }

            return mapper.readValue(responseBody, responseType);

        } catch (JsonProcessingException e) {
            log.error("Failed to parse response from {}: {}", url, e.getMessage());
            throw new ExternalServiceException(EXTERNAL_SERVICE_ERROR, "Failed to parse response");
        } catch (RestClientException ex) {
            log.error("Error calling external API: {} - {}", url, ex.getMessage(), ex);
            throw new ExternalServiceException(EXTERNAL_API_CALL_FAILED, "RestClientException");
        }
    }
}

