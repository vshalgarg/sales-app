package com.code.monks.csm.dto.email;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class DailyReportResult {
    private boolean success;
    private String message;
    private String reportDate;
    private String providerMessageId;
}
