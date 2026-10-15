package com.code.monks.csm.schedular;

import com.code.monks.csm.client.AuthUserEmailClient;
import com.code.monks.csm.dto.email.DailySalesReportDto;
import com.code.monks.csm.service.DailySalesReportService;
import com.code.monks.csm.service.ResendEmailService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

@Component
public class DailyReportScheduler {

    private static final Logger log =
            LoggerFactory.getLogger(DailyReportScheduler.class);

    private static final ZoneId INDIA_ZONE =
            ZoneId.of("Asia/Kolkata");

    private final DailySalesReportService reportService;
    private final AuthUserEmailClient authUserEmailClient;
    private final ResendEmailService resendEmailService;

    public DailyReportScheduler(
            DailySalesReportService reportService,
            AuthUserEmailClient authUserEmailClient,
            ResendEmailService resendEmailService) {
        this.reportService = reportService;
        this.authUserEmailClient = authUserEmailClient;
        this.resendEmailService = resendEmailService;
    }

    @Scheduled(
            cron = "${daily-report.cron:0 0 8 * * *}",
            zone = "Asia/Kolkata"
    )
    public void sendDailySalesReport() {

        // Report the previous calendar day in India.
        LocalDate reportDate = LocalDate.now(INDIA_ZONE).minusDays(1);

        log.info("Starting daily sales report for {}", reportDate);

        // Calculate the report once, not once per recipient.
        DailySalesReportDto report =
                reportService.generateReport(reportDate);

        List<String> recipients =
                authUserEmailClient.getAllUserEmails();

        if (recipients.isEmpty()) {
            log.warn("No recipients found for daily sales report");
            return;
        }

        int successCount = 0;
        int failureCount = 0;

        for (String recipient : recipients) {
            try {
                resendEmailService.sendDailyReport(recipient, report);
                successCount++;
            } catch (Exception ex) {
                failureCount++;
                log.error(
                        "Failed to submit daily report for recipient {}",
                        recipient,
                        ex
                );
            }
        }

        log.info(
                "Daily report finished for {}. Recipients: {}, "
                        + "accepted: {}, failed: {}",
                reportDate,
                recipients.size(),
                successCount,
                failureCount
        );
    }
}

