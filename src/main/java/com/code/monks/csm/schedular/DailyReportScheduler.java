package com.code.monks.csm.schedular;

import com.code.monks.csm.client.AuthRestClient;
import com.code.monks.csm.dto.email.DailyReportResult;
import com.code.monks.csm.dto.email.DailySalesReportDto;
import com.code.monks.csm.service.DailySalesReportService;
import com.code.monks.csm.service.ResendEmailService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DailyReportScheduler {
    private static final ZoneId INDIA_ZONE = ZoneId.of("Asia/Kolkata");
    private final DailySalesReportService reportService;
    private final AuthRestClient authRestClient;
    private final ResendEmailService resendEmailService;
//    @Scheduled(cron = "${daily-report.cron:0 0 9 * * *}", zone = "Asia/Kolkata")
      @Scheduled(
        cron = "${daily-report.cron:0 */5 * * * *}",
        zone = "Asia/Kolkata"
      )

    public void scheduledDailySalesReport() {
        try {
            DailyReportResult result = sendDailySalesReport();
            log.info(
                    "Scheduled daily report completed. Date: {}, recipients: {}, accepted: {}, failed: {}",
                    LocalDate.now(INDIA_ZONE).minusDays(1),
                    result.getTotalRecipients(),
                    result.getAccepted(),
                    result.getFailed()
            );
        } catch (Exception ex) {
            log.error("Daily sales report process failed", ex);
        }
    }

    public DailyReportResult sendDailySalesReport() {
        LocalDate reportDate = LocalDate.now(INDIA_ZONE).minusDays(1);
        log.info("Starting daily sales report for {}", reportDate);
        DailySalesReportDto report = reportService.generateReport(reportDate);
        List<String> recipients = authRestClient.getAllUserEmails();
        if (recipients == null || recipients.isEmpty()) {
            log.warn("No recipients found for daily sales report");
            return new DailyReportResult(0, 0, 0);
        }
        int accepted = 0;
        int failed = 0;
        for (String recipient : recipients) {
            log.warn("Recipient:",recipient);
            if (!isValidEmail(recipient)) {
                failed++;
                log.warn("Skipping an invalid or empty email recipient");
                continue;
            }
            try {
                String messageId = resendEmailService.sendDailyReport(recipient.trim(), report);
                accepted++;
                log.info("Daily report accepted by Resend. Message ID: {}", messageId);

            }
         catch (org.springframework.web.client.RestClientResponseException ex) {
            failed++;
            log.error("Resend failed. HTTP status: {}, response body: {}", ex.getStatusCode().value(), ex.getResponseBodyAsString());
            } catch (Exception ex) {
            failed++;
            log.error("Email submission failed. Exception: {}", ex.getClass().getSimpleName(), ex
            );
        }

    }
        log.info(
                "Daily report finished for {}. Recipients: {}, accepted: {}, failed: {}",
                reportDate,
                recipients.size(),
                accepted,
                failed
        );
        return new DailyReportResult(
                recipients.size(),
                accepted,
                failed
        );
    }

    private boolean isValidEmail(String email) {
        return email != null && email.trim().matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }
}