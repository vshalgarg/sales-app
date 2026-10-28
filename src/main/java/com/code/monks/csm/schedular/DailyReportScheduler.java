
package com.code.monks.csm.schedular;

import com.code.monks.csm.client.AuthRestClient;
import com.code.monks.csm.dto.email.DailyReportResult;
import com.code.monks.csm.dto.email.DailySalesReportDto;
import com.code.monks.csm.dto.request.SendEmailRequestDTO;
import com.code.monks.csm.dto.response.SendEmailResponseDTO;
import com.code.monks.csm.service.DailySalesReportService;
import java.time.format.DateTimeFormatter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import java.math.BigInteger;
import java.text.NumberFormat;
import java.util.Locale;
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
            cron = "${daily-report.cron}",
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
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");

        String formattedDate = report.getReportDate().format(formatter);
        BigInteger netDifference = report.getTotalCreditAmount()
                .subtract(report.getTotalDebitAmount());

        NumberFormat currencyFormat = NumberFormat.getNumberInstance(
                Locale.forLanguageTag("en-IN")
        );
        currencyFormat.setMinimumFractionDigits(0);
        currencyFormat.setMaximumFractionDigits(2);

        String totalCredit = "₹" + currencyFormat.format(
                report.getTotalCreditAmount()
        );

        String totalDebit = "₹" + currencyFormat.format(
                report.getTotalDebitAmount()
        );

        String formattedNetDifference = (netDifference.signum() < 0 ? "-₹" : "₹")
                + currencyFormat.format(netDifference.abs());

        String dailyInsight;

        if (netDifference.signum() < 0) {
            dailyInsight = "Debit transactions exceeded credit transactions by <strong>"
                    + formattedNetDifference + "</strong> for the day.";
        } else if (netDifference.signum() > 0) {
            dailyInsight = "Credit transactions exceeded debit transactions by <strong>"
                    + formattedNetDifference + "</strong> for the day.";
        } else {
            dailyInsight = "Total credit and debit amounts were equal for the day.";
        }

        return """
            <!DOCTYPE html>
            <html>
            <body style="margin:0; padding:0; background-color:#f4f6f8;
                         font-family:Arial,Helvetica,sans-serif; color:#263238;">

                <div style="max-width:680px; margin:24px auto; background:#ffffff;
                            border:1px solid #e5e7eb; border-radius:10px;
                            overflow:hidden;">

                    <div style="background:#173b57; padding:24px 28px; color:#ffffff;">
                        <h2 style="margin:0; font-size:24px;">Daily Business Summary</h2>
                        <p style="margin:8px 0 0; color:#e2e8f0; font-size:14px;">
                            Report Date: %s
                        </p>
                    </div>

                    <div style="padding:24px 28px;">
                        <p style="margin-top:0;">Hi,</p>
                        <p>
                            Please find below the daily business summary for
                            <strong>%s</strong>.
                        </p>

                        <h3 style="color:#173b57; margin-top:28px;">Daily Summary</h3>
                        <table style="width:100%%; border-collapse:collapse;">
                            <tr>
                                <td style="padding:12px; border-bottom:1px solid #e5e7eb;">
                                    <strong>Total Credit</strong>
                                </td>
                                <td style="padding:12px; text-align:right;
                                           border-bottom:1px solid #e5e7eb;">%s</td>
                            </tr>
                            <tr>
                                <td style="padding:12px; border-bottom:1px solid #e5e7eb;">
                                    <strong>Total Debit</strong>
                                </td>
                                <td style="padding:12px; text-align:right;
                                           border-bottom:1px solid #e5e7eb;">%s</td>
                            </tr>
                            <tr style="background:#f0f5f9;">
                                <td style="padding:12px; border-bottom:1px solid #e5e7eb;">
                                    <strong>Net Difference</strong>
                                </td>
                                <td style="padding:12px; text-align:right;
                                           border-bottom:1px solid #e5e7eb;">
                                    <strong>%s</strong>
                                </td>
                            </tr>
                        </table>

                        <h3 style="color:#173b57; margin-top:28px;">
                            Transaction Overview
                        </h3>
                        <table style="width:100%%; border-collapse:collapse;">
                            <tr>
                                <td style="padding:10px; border-bottom:1px solid #e5e7eb;">
                                    Total Bills
                                </td>
                                <td style="padding:10px; text-align:right;
                                           border-bottom:1px solid #e5e7eb;">%s</td>
                            </tr>
                            <tr>
                                <td style="padding:10px; border-bottom:1px solid #e5e7eb;">
                                    Credit Transactions
                                </td>
                                <td style="padding:10px; text-align:right;
                                           border-bottom:1px solid #e5e7eb;">%s</td>
                            </tr>
                        </table>

                        <h3 style="color:#173b57; margin-top:28px;">
                            Business Overview
                        </h3>
                        <table style="width:100%%; border-collapse:collapse;">
                            <tr>
                                <td style="padding:10px; border-bottom:1px solid #e5e7eb;">
                                    Customers
                                </td>
                                <td style="padding:10px; text-align:right;
                                           border-bottom:1px solid #e5e7eb;">%s</td>
                            </tr>
                            <tr>
                                <td style="padding:10px; border-bottom:1px solid #e5e7eb;">
                                    Suppliers
                                </td>
                                <td style="padding:10px; text-align:right;
                                           border-bottom:1px solid #e5e7eb;">%s</td>
                            </tr>
                            <tr>
                                <td style="padding:10px; border-bottom:1px solid #e5e7eb;">
                                    Retailers
                                </td>
                                <td style="padding:10px; text-align:right;
                                           border-bottom:1px solid #e5e7eb;">%s</td>
                            </tr>
                        </table>

                        <h3 style="color:#173b57; margin-top:28px;">Daily Insight</h3>
                        <p style="background:#f0f5f9; padding:16px; border-radius:6px;
                                  line-height:1.6; margin-bottom:28px;">
                            %s
                        </p>

                        <p style="margin-bottom:4px;">Regards,</p>
                        <p style="margin-top:4px;"><strong>Team Hisabio</strong></p>
                    </div>

                    <div style="background:#f4f6f8; padding:14px 28px;
                                color:#64748b; font-size:12px; text-align:center;">
                        This is an automated daily business summary.
                    </div>
                </div>
            </body>
            </html>
            """.formatted(
                formattedDate,
                formattedDate,
                totalCredit,
                totalDebit,
                formattedNetDifference,
                report.getTotalBills(),
                report.getTotalCredits(),
                report.getTotalCustomers(),
                report.getTotalSuppliers(),
                report.getTotalRetailers(),
                dailyInsight
        );
    }
}
