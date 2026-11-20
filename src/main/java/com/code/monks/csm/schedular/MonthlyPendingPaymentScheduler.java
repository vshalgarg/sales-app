package com.code.monks.csm.schedular;

import com.code.monks.csm.client.AuthRestClient;
import com.code.monks.csm.dto.ledger.PendingPaymentReportDTO;
import com.code.monks.csm.dto.request.EmailAttachmentDTO;
import com.code.monks.csm.dto.request.SendEmailRequestDTO;
import com.code.monks.csm.dto.response.SendEmailResponseDTO;
import com.code.monks.csm.service.PendingPaymentReportService;
import com.code.monks.csm.service.impl.EmailTemplateService;
import com.code.monks.csm.service.impl.PdfGeneratorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
@RequiredArgsConstructor
@Slf4j
public class MonthlyPendingPaymentScheduler {

    private static final ZoneId REPORT_ZONE = ZoneId.of("Asia/Kolkata");
    private final PendingPaymentReportService reportService;
    private final EmailTemplateService emailTemplateService;
    private final PdfGeneratorService pdfGeneratorService;
    private final AuthRestClient authRestClient;

    @Value("${daily-report.recipients}")
    private List<String> recipients;

    @Scheduled(
            cron = "${monthly-pending-report.cron}",
            zone = "${monthly-pending-report.timezone:Asia/Kolkata}"
    )
    public void sendMonthlyPendingPaymentReport() {
        YearMonth reportMonth = YearMonth.now(REPORT_ZONE).minusMonths(1);
        LocalDate asOfDate = reportMonth.atEndOfMonth();
        try {
            log.info("Generating monthly pending payment report for {} as of {}", reportMonth, asOfDate);
            List<PendingPaymentReportDTO> pendingPayments = reportService.getPendingPayments(asOfDate);
            BigDecimal totalOutstanding = reportService.getTotalOutstanding(pendingPayments);
            Map<String, Object> variables = new HashMap<>();
            variables.put("reportMonth", reportMonth.format(DateTimeFormatter.ofPattern("MMMM yyyy")));
            variables.put("pendingPayments", pendingPayments);
            variables.put("totalOutstanding", totalOutstanding);
            String reportHtml = emailTemplateService.processTemplate("monthly-pending-payment", variables);
            byte[] pdfBytes = pdfGeneratorService.generatePdf(reportHtml);
            String fileName = "Monthly-Pending-Payment-" + reportMonth + ".pdf";
            String base64Pdf = Base64.getEncoder().encodeToString(pdfBytes);
            EmailAttachmentDTO attachment = new EmailAttachmentDTO(fileName, "application/pdf", base64Pdf);

            String emailBody = """
                    <html>
                    <body style="font-family: Arial, sans-serif;">
                        <p>Hello,</p>
                        <p>
                            Please find attached the monthly pending customer payment report for %s.
                        </p>
                        <p>
                        The report includes details of outstanding customer payments for your reference.
                        </p>
                        <p>Regards,<br/>Hisabio</p>
                    </body>
                    </html>
                    """.formatted(
                    reportMonth.format(DateTimeFormatter.ofPattern("MMMM yyyy"))
            );

            SendEmailRequestDTO request = new SendEmailRequestDTO(
                            recipients,
                            "Monthly Pending Customer Payment Report - "
                                    + reportMonth.format(DateTimeFormatter.ofPattern("MMMM yyyy")),
                            emailBody,
                            List.of(attachment)
                    );
            SendEmailResponseDTO response = authRestClient.sendEmail(request);
            if (response == null || !response.isSuccess()) {
                log.error("Monthly pending payment email failed for {}", reportMonth);
                return;
            }
            log.info("Monthly pending payment PDF sent successfully for {}", reportMonth);
        } catch (Exception exception) {
            log.error("Error while generating or sending monthly pending payment PDF for {}", reportMonth, exception);
        }
    }
}
