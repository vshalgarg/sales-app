
package com.code.monks.csm.schedular;

import com.code.monks.csm.client.AuthRestClient;
import com.code.monks.csm.dto.email.DailyReportResult;
import com.code.monks.csm.dto.email.DailySalesReportDto;
import com.code.monks.csm.dto.request.SendEmailRequestDTO;
import com.code.monks.csm.dto.response.SendEmailResponseDTO;
import com.code.monks.csm.service.DailySalesReportService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;

@Component
@RequiredArgsConstructor
@Slf4j
public class DailyReportScheduler {

    private static final ZoneId REPORT_ZONE =
            ZoneId.of("Asia/Kolkata");

    private final DailySalesReportService reportService;
    private final AuthRestClient authRestClient;


    // Automatic daily execution at 9:00 AM IST by default
    @Scheduled(
            cron = "${daily-report.cron:0 */2 * * * *}",
            zone = "Asia/Kolkata"
    )
    public void sendDailyReport() {
        log.info("Daily report scheduler triggered at: {}", LocalDateTime.now());
        LocalDate reportDate =
                LocalDate.now(REPORT_ZONE).minusDays(1);

        sendReport(reportDate);
    }

    // Manual execution from AdminController
    public DailyReportResult sendDailySalesReport() {
        LocalDate reportDate =
                LocalDate.now(REPORT_ZONE).minusDays(1);

        return sendReport(reportDate);
    }


    private DailyReportResult sendReport(LocalDate reportDate) {
        DailySalesReportDto report = reportService.generateReport(reportDate);

        String html = buildReportHtml(report);

        SendEmailRequestDTO request = new SendEmailRequestDTO(
                null,
                "Daily Sales Report - " + reportDate,
                html
        );

        SendEmailResponseDTO response = authRestClient.sendEmail(request);

        if (response == null || !response.isSuccess()) {
            throw new IllegalStateException(
                    "Auth service did not confirm email acceptance"
            );
        }

        log.info(
                "Daily sales report submission accepted by Auth. Date={}, messageId={}",
                reportDate,
                response.getProviderMessageId()
        );

        // Is response se actual recipient-level counts tabhi milenge
        // jab Auth API response mein ye counts explicitly return kare.
        return new DailyReportResult(0, 1, 0);
    }


    private String buildReportHtml(DailySalesReportDto report) {
        return """
                <html>
                <body>
                    <h2>Daily Sales Report</h2>
                    <p>Report date: %s</p>
                    <table border="1" cellpadding="8" cellspacing="0">
                        <tr><td>Total credit amount</td><td>%s</td></tr>
                        <tr><td>Total debit amount</td><td>%s</td></tr>
                        <tr><td>Total bills</td><td>%s</td></tr>
                        <tr><td>Total credits</td><td>%s</td></tr>
                        <tr><td>Total retailers</td><td>%s</td></tr>
                        <tr><td>Total suppliers</td><td>%s</td></tr>
                        <tr><td>Total customers</td><td>%s</td></tr>
                    </table>
                </body>
                </html>
                """.formatted(
                report.getReportDate(),
                report.getTotalCreditAmount(),
                report.getTotalDebitAmount(),
                report.getTotalBills(),
                report.getTotalCredits(),
                report.getTotalRetailers(),
                report.getTotalSuppliers(),
                report.getTotalCustomers()
        );
    }
}
