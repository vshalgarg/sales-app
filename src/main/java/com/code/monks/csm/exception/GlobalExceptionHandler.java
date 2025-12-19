package com.code.monks.csm.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(DuplicateEntryException.class)
    public ResponseEntity<ErrorResponse> handleValidationException(DuplicateEntryException ex) {
        ErrorResponse errorResponse = new ErrorResponse(ex.getCode(),ex.getMessage(),LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFoundException(ResourceNotFoundException ex) {
        ErrorResponse errorResponse = new ErrorResponse(ex.getErrorCode().getCode(), ex.getMessage(),LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

    @ExceptionHandler(StaffException.class)
    public ResponseEntity<ErrorResponse> handleStaffException(StaffException ex) {
        ErrorResponse errorResponse = new ErrorResponse(ex.getCode(),ex.getMessage(),LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

    @ExceptionHandler(CreditException.class)
    public ResponseEntity<ErrorResponse> handleCreditException(CreditException ex) {
        ErrorResponse errorResponse = new ErrorResponse(ex.getErrorCode().getCode(), ex.getMessage(),LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

    @ExceptionHandler(CustomerException.class)
    public ResponseEntity<ErrorResponse> handleStaffException(CustomerException ex) {
        ErrorResponse errorResponse = new ErrorResponse(ex.getCode(),ex.getMessage(),LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

    @ExceptionHandler(SupplierException.class)
    public ResponseEntity<ErrorResponse> handleStaffException(SupplierException ex) {
        ErrorResponse errorResponse = new ErrorResponse(ex.getErrorCode().getCode(),ex.getMessage(),LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

    @ExceptionHandler(BillException.class)
    public ResponseEntity<ErrorResponse> handleStaffException(BillException ex) {
        ErrorResponse errorResponse = new ErrorResponse(ex.getCode(),ex.getMessage(),LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

    @ExceptionHandler(ExternalServiceException.class)
    public ResponseEntity<ErrorResponse> handleExternalServerErrors(ExternalServiceException ex) {
        String combined = ex.getMessage();
        int code;
        String message;

        if (combined != null && combined.contains("::")) {
            String[] parts = combined.split("::", 2);
            try {
                code = Integer.parseInt(parts[0].trim());
            } catch (NumberFormatException e) {
                code = 500;
            }
            message = parts.length > 1 ? parts[1].trim() : "No message provided";
        } else {
            code = 500;
            message = combined != null ? combined : "Unknown error";
        }

        ErrorResponse error = new ErrorResponse(code, message, LocalDateTime.now());
        return new ResponseEntity<>(error, HttpStatus.OK);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleGenericException(Exception ex) {
        ErrorResponse errorResponse = new ErrorResponse(500,ex.getMessage(),LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidationExceptions(MethodArgumentNotValidException ex) {
        List<String> errorMessages = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .map(FieldError::getDefaultMessage)
                .collect(Collectors.toList());

        String combinedMessage = String.join("; ", errorMessages);

        ErrorResponse errorResponse = new ErrorResponse(
                HttpStatus.BAD_REQUEST.value(),
                combinedMessage,
                LocalDateTime.now()
        );

        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

}
