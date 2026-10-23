package com.code.monks.csm.service;

import com.code.monks.csm.dto.email.DailySalesReportDto;
import com.code.monks.csm.dto.email.ResendEmailResponse;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClient;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Slf4j
@Service
public class ResendEmailService {

    private final RestClient restClient;
    private final String apiKey;
    private final String fromEmail;
    private final String apiUrl;

    public ResendEmailService(
            RestClient.Builder restClientBuilder,
            @Value("${resend.api-url}") String apiUrl,
            @Value("${resend.api-key}") String apiKey,
            @Value("${resend.from-email}") String fromEmail) {

        this.apiUrl = apiUrl.replaceAll("/+$", "");
        this.restClient = restClientBuilder.build();
        this.apiKey = apiKey;
        this.fromEmail = fromEmail;

        log.info("Resend base URL configured: {}", this.apiUrl);
    }

    public String sendDailyReport(
            String recipient,
            DailySalesReportDto report) {

        if (recipient == null || recipient.isBlank()) {
            throw new IllegalArgumentException(
                    "Recipient email must not be empty"
            );
        }

        String subject =
                "Daily Sales Report - " + report.getReportDate();

        Map<String, Object> requestBody = Map.of(
                "from", fromEmail,
                "to", List.of(recipient.trim()),
                "subject", subject,
                "html", buildHtml(report)
        );

        String url = apiUrl + "/emails";

        try {
            ResendEmailResponse response = restClient.post()
                    .uri(url)
                    .header("Authorization", "Bearer " + apiKey)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(requestBody)
                    .retrieve()
                    .body(ResendEmailResponse.class);

            if (response == null
                    || response.getId() == null
                    || response.getId().isBlank()) {
                throw new IllegalStateException(
                        "Resend did not return an email message ID"
                );
            }

            log.info(
                    "Resend accepted daily report. Message ID: {}",
                    response.getId()
            );

            return response.getId();

        } catch (Exception ex) {
            log.error(
                    "Resend email request failed. Exception type: {}",
                    ex.getClass().getSimpleName()
            );
            throw ex;
        }
    }

    private String buildHtml(DailySalesReportDto report) {
        NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "IN"));
        String totalCreditAmount = currencyFormat.format(report.getTotalCreditAmount());
        String totalDebitAmount = currencyFormat.format(report.getTotalDebitAmount());

        return """
                <!DOCTYPE html>
                <html>
                <body style="margin:0;padding:24px;background:#f4f6f9;
                             font-family:Arial,sans-serif;color:#202938;">
                  <div style="max-width:680px;margin:auto;background:#ffffff;
                              border-radius:12px;padding:28px;">
                    <h2 style="margin-top:0;">Daily Sales Report</h2>

                    <p>Here is the sales activity summary for
                       <strong>%s</strong>.</p>

                    <table style="width:100%%;border-collapse:collapse;">
                      <tr>
                        <td style="padding:14px;border-bottom:1px solid #e5e7eb;">
                          Total Credit Amount
                        </td>
                        <td style="padding:14px;text-align:right;
                                   border-bottom:1px solid #e5e7eb;">
                          <strong>%s</strong>
                        </td>
                      </tr>
                      <tr>
                        <td style="padding:14px;border-bottom:1px solid #e5e7eb;">
                          Total Debit Amount
                        </td>
                        <td style="padding:14px;text-align:right;
                                   border-bottom:1px solid #e5e7eb;">
                          <strong>%s</strong>
                        </td>
                      </tr>
                      <tr>
                        <td style="padding:14px;border-bottom:1px solid #e5e7eb;">
                          Total Bills
                        </td>
                        <td style="padding:14px;text-align:right;
                                   border-bottom:1px solid #e5e7eb;">%d</td>
                      </tr>
                      <tr>
                        <td style="padding:14px;border-bottom:1px solid #e5e7eb;">
                          Total Credit Entries
                        </td>
                        <td style="padding:14px;text-align:right;
                                   border-bottom:1px solid #e5e7eb;">%d</td>
                      </tr>
                      <tr>
                        <td style="padding:14px;border-bottom:1px solid #e5e7eb;">
                          Retailers Worked On
                        </td>
                        <td style="padding:14px;text-align:right;
                                   border-bottom:1px solid #e5e7eb;">%d</td>
                      </tr>
                      <tr>
                        <td style="padding:14px;border-bottom:1px solid #e5e7eb;">
                          Suppliers Worked On
                        </td>
                        <td style="padding:14px;text-align:right;
                                   border-bottom:1px solid #e5e7eb;">%d</td>
                      </tr>
                      <tr>
                        <td style="padding:14px;">Customers Worked On</td>
                        <td style="padding:14px;text-align:right;">%d</td>
                      </tr>
                    </table>

                    <p style="margin-top:28px;color:#6b7280;font-size:12px;">
                      This is an automatically generated report.
                      Please do not reply to this email.
                    </p>
                  </div>
                </body>
                </html>
                """.formatted(
                report.getReportDate(),
                totalCreditAmount,
                totalDebitAmount,
                report.getTotalBills(),
                report.getTotalCredits(),
                report.getTotalRetailers(),
                report.getTotalSuppliers(),
                report.getTotalCustomers()
        );
    }
}