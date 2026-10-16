package com.code.monks.csm.dto.email;
import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class DailyReportResult {
    private final int totalRecipients;
    private final int accepted;
    private final int failed;
}
