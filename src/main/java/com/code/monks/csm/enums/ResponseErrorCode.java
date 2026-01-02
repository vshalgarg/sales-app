package com.code.monks.csm.enums;

import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public enum ResponseErrorCode {

    EXTERNAL_SERVICE_ERROR(1001, "External service exception occurred."),
    EXTERNAL_API_CALL_FAILED(1002,"External api call failed"),
    ADD_STAFF_EXCEPTION(1003,"Add staff exception occur"),
    GET_STAFF_EXCEPTION(1004,"Get staff exception occur"),
    DATA_NOT_FOUND(1111,"Data not found. "),
    DUPLICATE_ENTRY(1005,""),
    UNEXPECTED_EXCEPTION(1006,"Unexpected error occur while "),
    DATA_ACCESS_ERROR(1007, "Data access error occurred."),
    TRANSPORT_NOT_FOUND(1008,"Transport not found"),
    PREFERRED_TRANSPORT_NOT_FOUND(1008,"One or more preferred transport IDs are invalid"),
    INVALID_REQUEST(1009,"Invalid request");

    private final int code;
    private final String message;

}
