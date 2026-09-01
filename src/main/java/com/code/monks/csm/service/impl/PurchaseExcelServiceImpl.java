package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.response.PurchaseHistoryResponseDto;
import com.code.monks.csm.enums.ResponseErrorCode;
import com.code.monks.csm.exception.ExcelGenerationException;
import com.code.monks.csm.service.PurchaseExcelService;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFColor;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;

@Service
@Slf4j
public class PurchaseExcelServiceImpl implements PurchaseExcelService {

    private static final String DATE_FORMAT = "dd-MM-yyyy";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern(DATE_FORMAT);
    private static final DateTimeFormatter PERIOD_FORMAT = DateTimeFormatter.ofPattern("MMMyy", Locale.ENGLISH);
    private static final DateTimeFormatter GENERATED_AT_FORMAT = DateTimeFormatter.ofPattern("dd_MM_yyyy_HH_mm_ss");

    private static final int DATA_LAST_COL = 4;
    private static final byte[] HEADER_BLUE = {(byte) 68, (byte) 114, (byte) 196};

    @Override
    public byte[] generateExcel(List<PurchaseHistoryResponseDto> entries, LocalDate fromDate, LocalDate toDate) {
        List<PurchaseHistoryResponseDto> rows = entries != null ? entries : List.of();
        log.info("Generating purchase Excel: entries={}, fromDate={}, toDate={}", rows.size(), fromDate, toDate);

        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Styles styles = createStyles(workbook);
            Sheet dataSheet = workbook.createSheet("Purchase Data");
            writeDataSheet(dataSheet, rows, resolveReportPeriod(rows, fromDate, toDate), styles);

            workbook.write(out);
            byte[] result = out.toByteArray();
            log.info("Purchase Excel generated: entries={}, size={} bytes", rows.size(), result.length);
            return result;

        } catch (Exception e) {
            throw new ExcelGenerationException(ResponseErrorCode.EXCEL_GENERATION_FAILED, e);
        }
    }

    @Override
    public String buildPurchaseExcelFilename(List<PurchaseHistoryResponseDto> entries, LocalDate fromDate, LocalDate toDate) {
        List<PurchaseHistoryResponseDto> rows = entries != null ? entries : List.of();
        ReportPeriod period = resolveReportPeriod(rows, fromDate, toDate);
        String generatedAt = LocalDateTime.now().format(GENERATED_AT_FORMAT);

        if (period.fromDate() != null && period.toDate() != null) {
            return String.format(
                    "Purchases_%s_%s_%s.xlsx",
                    period.fromDate().format(PERIOD_FORMAT),
                    period.toDate().format(PERIOD_FORMAT),
                    generatedAt
            );
        }
        if (period.fromDate() != null) {
            return String.format("Purchases_%s_%s.xlsx", period.fromDate().format(PERIOD_FORMAT), generatedAt);
        }
        if (period.toDate() != null) {
            return String.format("Purchases_%s_%s.xlsx", period.toDate().format(PERIOD_FORMAT), generatedAt);
        }
        return "Purchases_" + generatedAt + ".xlsx";
    }

    private ReportPeriod resolveReportPeriod(
            List<PurchaseHistoryResponseDto> entries,
            LocalDate fromDate,
            LocalDate toDate
    ) {
        LocalDate minDate = null;
        LocalDate maxDate = null;
        for (PurchaseHistoryResponseDto entry : entries) {
            LocalDate date = entry.getDate();
            if (date == null) {
                continue;
            }
            if (minDate == null || date.isBefore(minDate)) {
                minDate = date;
            }
            if (maxDate == null || date.isAfter(maxDate)) {
                maxDate = date;
            }
        }
        return new ReportPeriod(
                fromDate != null ? fromDate : minDate,
                toDate != null ? toDate : maxDate
        );
    }

    private String buildDataSheetTitle(ReportPeriod period) {
        if (period.fromDate() != null && period.toDate() != null) {
            return String.format(
                    "PURCHASE DATA (%s to %s)",
                    period.fromDate().format(DATE_FORMATTER),
                    period.toDate().format(DATE_FORMATTER)
            );
        }
        if (period.fromDate() != null) {
            return "PURCHASE DATA (" + period.fromDate().format(DATE_FORMATTER) + ")";
        }
        if (period.toDate() != null) {
            return "PURCHASE DATA (" + period.toDate().format(DATE_FORMATTER) + ")";
        }
        return "PURCHASE DATA";
    }

    private void writeDataSheet(Sheet sheet, List<PurchaseHistoryResponseDto> rows, ReportPeriod period, Styles styles) {
        int rowNum = 0;
        writeSectionTitle(sheet, rowNum++, styles.titleStyle, buildDataSheetTitle(period));
        writeDataHeader(sheet, rowNum++, styles.dataHeaderStyle);
        writeDataRows(sheet, rowNum, rows, styles);
        setDataColumnWidths(sheet);
        sheet.setFitToPage(true);
        sheet.setPrintGridlines(false);
        sheet.createFreezePane(0, 2);
    }

    private void writeSectionTitle(Sheet sheet, int rowNum, CellStyle style, String title) {
        Row row = sheet.createRow(rowNum);
        row.setHeightInPoints(28);
        for (int i = 0; i <= DATA_LAST_COL; i++) {
            Cell cell = row.createCell(i);
            if (i == 0) {
                cell.setCellValue(title);
            }
            cell.setCellStyle(style);
        }
        sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, 0, DATA_LAST_COL));
    }

    private void writeDataHeader(Sheet sheet, int rowNum, CellStyle style) {
        Row row = sheet.createRow(rowNum);
        row.setHeightInPoints(22);
        String[] headers = {"Date", "Staff", "Supplier", "Customer", "Remarks"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = row.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(style);
        }
    }

    private void writeDataRows(Sheet sheet, int rowNum, List<PurchaseHistoryResponseDto> entries, Styles styles) {
        for (PurchaseHistoryResponseDto entry : entries) {
            Row row = sheet.createRow(rowNum++);

            Cell dateCell = row.createCell(0);
            if (entry.getDate() != null) {
                dateCell.setCellValue(entry.getDate());
            }
            dateCell.setCellStyle(styles.dataDateStyle);

            setText(row, 1, entry.getStaffName(), styles.dataTextStyle);
            setText(row, 2, entry.getSupplierName(), styles.dataTextStyle);
            setText(row, 3, entry.getCustomerName(), styles.dataTextStyle);
            setText(row, 4, entry.getRemarks(), styles.dataRemarksStyle);
        }
    }

    private void setText(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value != null ? value : "");
        cell.setCellStyle(style);
    }

    private Styles createStyles(Workbook wb) {
        Font titleFont = wb.createFont();
        titleFont.setBold(true);
        titleFont.setFontName("Calibri");
        titleFont.setFontHeightInPoints((short) 16);
        titleFont.setColor(IndexedColors.BLUE.getIndex());

        XSSFCellStyle titleStyle = (XSSFCellStyle) wb.createCellStyle();
        titleStyle.setFont(titleFont);
        titleStyle.setAlignment(HorizontalAlignment.LEFT);
        titleStyle.setVerticalAlignment(VerticalAlignment.CENTER);

        Font headerFont = wb.createFont();
        headerFont.setBold(true);
        headerFont.setFontName("Calibri");
        headerFont.setFontHeightInPoints((short) 11);
        headerFont.setColor(IndexedColors.WHITE.getIndex());

        XSSFCellStyle dataHeaderStyle = filledHeader(wb, headerFont, HEADER_BLUE);

        Font bodyFont = wb.createFont();
        bodyFont.setFontName("Calibri");
        bodyFont.setFontHeightInPoints((short) 11);

        CellStyle dataDateStyle = wb.createCellStyle();
        dataDateStyle.setFont(bodyFont);
        applyBorders(dataDateStyle, BorderStyle.THIN);
        dataDateStyle.setAlignment(HorizontalAlignment.CENTER);
        dataDateStyle.setVerticalAlignment(VerticalAlignment.CENTER);
        dataDateStyle.setDataFormat(wb.getCreationHelper().createDataFormat().getFormat(DATE_FORMAT));

        CellStyle dataTextStyle = wb.createCellStyle();
        dataTextStyle.setFont(bodyFont);
        applyBorders(dataTextStyle, BorderStyle.THIN);
        dataTextStyle.setAlignment(HorizontalAlignment.LEFT);
        dataTextStyle.setVerticalAlignment(VerticalAlignment.CENTER);

        CellStyle dataRemarksStyle = wb.createCellStyle();
        dataRemarksStyle.cloneStyleFrom(dataTextStyle);
        dataRemarksStyle.setWrapText(true);

        return new Styles(titleStyle, dataHeaderStyle, dataDateStyle, dataTextStyle, dataRemarksStyle);
    }

    private XSSFCellStyle filledHeader(Workbook wb, Font font, byte[] rgb) {
        XSSFCellStyle style = (XSSFCellStyle) wb.createCellStyle();
        style.setFont(font);
        style.setFillForegroundColor(new XSSFColor(rgb, null));
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        applyBorders(style, BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    private void applyBorders(CellStyle style, BorderStyle border) {
        style.setBorderTop(border);
        style.setBorderBottom(border);
        style.setBorderLeft(border);
        style.setBorderRight(border);
    }

    private void setDataColumnWidths(Sheet sheet) {
        sheet.setColumnWidth(0, 14 * 256);
        sheet.setColumnWidth(1, 18 * 256);
        sheet.setColumnWidth(2, 24 * 256);
        sheet.setColumnWidth(3, 24 * 256);
        sheet.setColumnWidth(4, 32 * 256);
    }

    private record ReportPeriod(LocalDate fromDate, LocalDate toDate) {}

    private record Styles(
            CellStyle titleStyle,
            CellStyle dataHeaderStyle,
            CellStyle dataDateStyle,
            CellStyle dataTextStyle,
            CellStyle dataRemarksStyle
    ) {}
}
