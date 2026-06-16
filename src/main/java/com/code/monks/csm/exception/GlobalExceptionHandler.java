package com.code.monks.csm.exception;

import com.code.monks.csm.enums.ResponseErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
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
@Slf4j
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

    @ExceptionHandler(FileUploadException.class)
    public ResponseEntity<ErrorResponse> handleFileUploadException(FileUploadException ex) {
        ErrorResponse errorResponse = new ErrorResponse(ex.getErrorCode().getCode(), ex.getMessage(),LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

    @ExceptionHandler(InvalidFileException.class)
    public ResponseEntity<ErrorResponse> handleInvalidFileException(InvalidFileException ex) {
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

        log.error("Unhandled exception occurred", ex);

        ErrorResponse errorResponse = new ErrorResponse(
                500,
                "Something went wrong. Please try again later.",
                LocalDateTime.now()
        );
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

    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<ErrorResponse> handleDataAccessException(DataAccessException ex) {

        log.error("[DATABASE ERROR] {}", ex.getMessage(), ex);

        ResponseErrorCode errorCode = ResponseErrorCode.DB_ERROR;
        ErrorResponse errorResponse = new ErrorResponse(
                errorCode.getCode(),
                errorCode.getMessage(),
                LocalDateTime.now()
        );

        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(errorResponse);
    }

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ErrorResponse> handleBusinessException(BusinessException ex) {
        ErrorResponse errorResponse = new ErrorResponse(ex.getErrorCode().getCode(), ex.getErrorCode().getMessage(),LocalDateTime.now());
        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

    @ExceptionHandler(ExcelGenerationException.class)
    public ResponseEntity<ErrorResponse> handleExcelGenerationException(ExcelGenerationException ex) {

        log.error("Excel generation failed: {}", ex.getMessage(), ex);
        ErrorResponse errorResponse = new ErrorResponse(
                ex.getCode(),
                ex.getMessage(),
                LocalDateTime.now()
        );
        return ResponseEntity.status(HttpStatus.OK).body(errorResponse);
    }

}
