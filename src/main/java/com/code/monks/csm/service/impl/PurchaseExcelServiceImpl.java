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
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.TreeMap;

@Service
@Slf4j
public class PurchaseExcelServiceImpl implements PurchaseExcelService {

    private static final String DATE_FORMAT = "dd-MM-yyyy";
    private static final String NUMBER_FORMAT = "#,##0";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern(DATE_FORMAT);
    private static final DateTimeFormatter PERIOD_FORMAT = DateTimeFormatter.ofPattern("MMMyy", Locale.ENGLISH);
    private static final DateTimeFormatter TIMESTAMP_FORMAT = DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss");

    private static final int REPORT_PERIOD_COL = 0;
    private static final int OVERALL_COL = 3;
    private static final int YEAR_WISE_COL = 6;
    private static final int TITLE_LAST_COL = 10;

    private static final byte[] DARK_BLUE = {(byte) 0, (byte) 32, (byte) 96};
    private static final byte[] GREEN = {(byte) 84, (byte) 130, (byte) 53};

    @Override
    public byte[] generateExcel(List<PurchaseHistoryResponseDto> entries, LocalDate fromDate, LocalDate toDate) {
        List<PurchaseHistoryResponseDto> rows = entries != null ? entries : List.of();
        log.info("Generating purchase Excel: entries={}, fromDate={}, toDate={}", rows.size(), fromDate, toDate);

        SummaryData summary = buildSummary(rows, fromDate, toDate);

        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Styles styles = createStyles(workbook);

            Sheet summarySheet = workbook.createSheet("Summary");
            writeSummarySheet(summarySheet, summary, styles);

            Sheet dataSheet = workbook.createSheet("Purchase Data");
            writeDataSheet(dataSheet, rows, styles);

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
        LocalDate minDate = null;
        LocalDate maxDate = null;
        for (PurchaseHistoryResponseDto entry : rows) {
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

        LocalDate periodFrom = fromDate != null ? fromDate : minDate;
        LocalDate periodTo = toDate != null ? toDate : maxDate;
        String timestamp = LocalDateTime.now().format(TIMESTAMP_FORMAT);

        if (periodFrom != null && periodTo != null) {
            return String.format(
                    "Purchases_%s_%s_%s.xlsx",
                    periodFrom.format(PERIOD_FORMAT),
                    periodTo.format(PERIOD_FORMAT),
                    timestamp
            );
        }
        if (periodFrom != null) {
            return String.format("Purchases_%s_%s.xlsx", periodFrom.format(PERIOD_FORMAT), timestamp);
        }
        if (periodTo != null) {
            return String.format("Purchases_%s_%s.xlsx", periodTo.format(PERIOD_FORMAT), timestamp);
        }
        return "Purchases_" + timestamp + ".xlsx";
    }

    private SummaryData buildSummary(List<PurchaseHistoryResponseDto> entries, LocalDate fromDate, LocalDate toDate) {
        Set<String> suppliers = new HashSet<>();
        Set<String> customers = new HashSet<>();
        Set<String> staff = new HashSet<>();
        TreeMap<Integer, YearAgg> byYear = new TreeMap<>(Comparator.reverseOrder());
        LocalDate minDate = null;
        LocalDate maxDate = null;

        for (PurchaseHistoryResponseDto entry : entries) {
            addIfPresent(suppliers, entry.getSupplierName());
            addIfPresent(customers, entry.getCustomerName());
            addIfPresent(staff, entry.getStaffName());

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

            YearAgg yearAgg = byYear.computeIfAbsent(date.getYear(), y -> new YearAgg());
            yearAgg.purchases++;
            addIfPresent(yearAgg.suppliers, entry.getSupplierName());
            addIfPresent(yearAgg.customers, entry.getCustomerName());
            addIfPresent(yearAgg.staff, entry.getStaffName());
        }

        LocalDate periodFrom = fromDate != null ? fromDate : minDate;
        LocalDate periodTo = toDate != null ? toDate : maxDate;
        int totalYears = 0;
        if (periodFrom != null && periodTo != null) {
            totalYears = Math.max(0, periodTo.getYear() - periodFrom.getYear() + 1);
        } else if (periodFrom != null || periodTo != null) {
            totalYears = 1;
        }

        return new SummaryData(
                periodFrom,
                periodTo,
                totalYears,
                entries.size(),
                suppliers.size(),
                customers.size(),
                staff.size(),
                byYear
        );
    }

    private void writeSummarySheet(Sheet sheet, SummaryData summary, Styles styles) {
        int rowNum = 0;
        writeSectionTitle(sheet, rowNum++, TITLE_LAST_COL, styles.titleStyle, "PURCHASES SUMMARY");
        rowNum++;
        writeSummaryTables(sheet, rowNum, summary, styles);
        setSummaryColumnWidths(sheet);
        sheet.setFitToPage(true);
        sheet.setPrintGridlines(false);
    }

    private void writeDataSheet(Sheet sheet, List<PurchaseHistoryResponseDto> rows, Styles styles) {
        int rowNum = 0;
        writeSectionTitle(sheet, rowNum++, 5, styles.titleStyle, "PURCHASE DATA (All Years)");
        writeDataHeader(sheet, rowNum++, styles.dataHeaderStyle);
        writeDataRows(sheet, rowNum, rows, styles);
        setDataColumnWidths(sheet);
        sheet.setFitToPage(true);
        sheet.setPrintGridlines(false);
        sheet.createFreezePane(0, 2);
    }

    private int writeSummaryTables(Sheet sheet, int startRow, SummaryData summary, Styles styles) {
        writeMergedHeader(sheet, startRow, REPORT_PERIOD_COL, REPORT_PERIOD_COL + 1,
                "Report Period", styles.darkBlueHeaderStyle);
        writeMergedHeader(sheet, startRow, OVERALL_COL, OVERALL_COL + 1,
                "Overall Summary", styles.greenHeaderStyle);

        Row yearHeader = getOrCreateRow(sheet, startRow);
        yearHeader.setHeightInPoints(22);
        String[] yearHeaders = {"Year", "Purchases", "Suppliers", "Customers", "Staff"};
        for (int i = 0; i < yearHeaders.length; i++) {
            Cell cell = yearHeader.createCell(YEAR_WISE_COL + i);
            cell.setCellValue(yearHeaders[i]);
            cell.setCellStyle(styles.greenHeaderStyle);
        }

        String[][] periodRows = {
                {"From Date", formatDate(summary.fromDate)},
                {"To Date", formatDate(summary.toDate)},
                {"Total Years", null}
        };
        for (int i = 0; i < periodRows.length; i++) {
            Row row = getOrCreateRow(sheet, startRow + 1 + i);
            Cell label = row.createCell(REPORT_PERIOD_COL);
            label.setCellValue(periodRows[i][0]);
            label.setCellStyle(styles.labelStyle);

            Cell value = row.createCell(REPORT_PERIOD_COL + 1);
            if (i == 2) {
                value.setCellValue(summary.totalYears);
            } else {
                value.setCellValue(periodRows[i][1]);
            }
            value.setCellStyle(styles.valueNumberStyle);
        }

        String[] overallLabels = {"Total Purchases", "Total Suppliers", "Total Customers", "Total Staff"};
        int[] overallValues = {summary.totalPurchases, summary.totalSuppliers, summary.totalCustomers, summary.totalStaff};
        for (int i = 0; i < overallLabels.length; i++) {
            Row row = getOrCreateRow(sheet, startRow + 1 + i);
            Cell label = row.createCell(OVERALL_COL);
            label.setCellValue(overallLabels[i]);
            label.setCellStyle(styles.labelStyle);

            Cell value = row.createCell(OVERALL_COL + 1);
            value.setCellValue(overallValues[i]);
            value.setCellStyle(styles.valueNumberStyle);
        }

        int yearRow = startRow + 1;
        for (var yearEntry : summary.byYear.entrySet()) {
            YearAgg agg = yearEntry.getValue();
            writeYearRow(sheet, yearRow++, String.valueOf(yearEntry.getKey()),
                    agg.purchases, agg.suppliers.size(), agg.customers.size(), agg.staff.size(),
                    styles.valueTextStyle, styles.valueNumberStyle);
        }
        writeYearRow(sheet, yearRow, "Grand Total",
                summary.totalPurchases, summary.totalSuppliers, summary.totalCustomers, summary.totalStaff,
                styles.grandTotalLabelStyle, styles.grandTotalNumberStyle);

        int periodEnd = startRow + periodRows.length;
        int overallEnd = startRow + overallLabels.length;
        return Math.max(yearRow, Math.max(periodEnd, overallEnd)) + 1;
    }

    private void writeYearRow(Sheet sheet, int rowNum, String yearLabel,
                              int purchases, int suppliers, int customers, int staff,
                              CellStyle labelStyle, CellStyle numberStyle) {
        Row row = getOrCreateRow(sheet, rowNum);
        Cell yearCell = row.createCell(YEAR_WISE_COL);
        yearCell.setCellValue(yearLabel);
        yearCell.setCellStyle(labelStyle);

        int[] values = {purchases, suppliers, customers, staff};
        for (int i = 0; i < values.length; i++) {
            Cell cell = row.createCell(YEAR_WISE_COL + 1 + i);
            cell.setCellValue(values[i]);
            cell.setCellStyle(numberStyle);
        }
    }

    private void writeSectionTitle(Sheet sheet, int rowNum, int lastCol, CellStyle style, String title) {
        Row row = sheet.createRow(rowNum);
        row.setHeightInPoints(28);
        for (int i = 0; i <= lastCol; i++) {
            Cell cell = row.createCell(i);
            if (i == 0) {
                cell.setCellValue(title);
            }
            cell.setCellStyle(style);
        }
        sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, 0, lastCol));
    }

    private void writeMergedHeader(Sheet sheet, int rowNum, int startCol, int endCol, String title, CellStyle style) {
        Row row = getOrCreateRow(sheet, rowNum);
        row.setHeightInPoints(22);
        for (int i = startCol; i <= endCol; i++) {
            Cell cell = row.createCell(i);
            if (i == startCol) {
                cell.setCellValue(title);
            }
            cell.setCellStyle(style);
        }
        if (endCol > startCol) {
            sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, startCol, endCol));
        }
    }

    private void writeDataHeader(Sheet sheet, int rowNum, CellStyle style) {
        Row row = getOrCreateRow(sheet, rowNum);
        row.setHeightInPoints(22);
        String[] headers = {"Purchase ID", "Date", "Staff", "Supplier", "Customer", "Remarks"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = row.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(style);
        }
    }

    private void writeDataRows(Sheet sheet, int rowNum, List<PurchaseHistoryResponseDto> entries, Styles styles) {
        for (PurchaseHistoryResponseDto entry : entries) {
            Row row = getOrCreateRow(sheet, rowNum++);

            Cell idCell = row.createCell(0);
            idCell.setCellValue(entry.getId());
            idCell.setCellStyle(styles.dataIdStyle);

            Cell dateCell = row.createCell(1);
            if (entry.getDate() != null) {
                dateCell.setCellValue(entry.getDate());
            }
            dateCell.setCellStyle(styles.dataDateStyle);

            setText(row, 2, entry.getStaffName(), styles.dataTextStyle);
            setText(row, 3, entry.getSupplierName(), styles.dataTextStyle);
            setText(row, 4, entry.getCustomerName(), styles.dataTextStyle);
            setText(row, 5, entry.getRemarks(), styles.dataRemarksStyle);
        }
    }

    private void setText(Row row, int col, String value, CellStyle style) {
        Cell cell = row.createCell(col);
        cell.setCellValue(value != null ? value : "");
        cell.setCellStyle(style);
    }

    private Row getOrCreateRow(Sheet sheet, int rowNum) {
        Row row = sheet.getRow(rowNum);
        return row != null ? row : sheet.createRow(rowNum);
    }

    private void addIfPresent(Set<String> set, String value) {
        if (value != null && !value.isBlank()) {
            set.add(value);
        }
    }

    private String formatDate(LocalDate date) {
        return date != null ? date.format(DATE_FORMATTER) : "";
    }

    private Styles createStyles(Workbook wb) {
        Font titleFont = wb.createFont();
        titleFont.setBold(true);
        titleFont.setFontName("Calibri");
        titleFont.setFontHeightInPoints((short) 16);
        titleFont.setColor(IndexedColors.DARK_BLUE.getIndex());

        XSSFCellStyle titleStyle = (XSSFCellStyle) wb.createCellStyle();
        titleStyle.setFont(titleFont);
        titleStyle.setAlignment(HorizontalAlignment.LEFT);
        titleStyle.setVerticalAlignment(VerticalAlignment.CENTER);

        Font headerFont = wb.createFont();
        headerFont.setBold(true);
        headerFont.setFontName("Calibri");
        headerFont.setFontHeightInPoints((short) 11);
        headerFont.setColor(IndexedColors.WHITE.getIndex());

        XSSFCellStyle darkBlueHeaderStyle = filledHeader(wb, headerFont, DARK_BLUE);
        XSSFCellStyle greenHeaderStyle = filledHeader(wb, headerFont, GREEN);
        XSSFCellStyle dataHeaderStyle = filledHeader(wb, headerFont, DARK_BLUE);

        Font labelFont = wb.createFont();
        labelFont.setBold(true);
        labelFont.setFontName("Calibri");
        labelFont.setFontHeightInPoints((short) 10);

        CellStyle labelStyle = wb.createCellStyle();
        labelStyle.setFont(labelFont);
        applyBorders(labelStyle, BorderStyle.THIN);
        labelStyle.setAlignment(HorizontalAlignment.LEFT);
        labelStyle.setVerticalAlignment(VerticalAlignment.CENTER);
        labelStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        labelStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

        Font bodyFont = wb.createFont();
        bodyFont.setFontName("Calibri");
        bodyFont.setFontHeightInPoints((short) 11);

        CellStyle valueTextStyle = wb.createCellStyle();
        valueTextStyle.setFont(bodyFont);
        applyBorders(valueTextStyle, BorderStyle.THIN);
        valueTextStyle.setAlignment(HorizontalAlignment.LEFT);
        valueTextStyle.setVerticalAlignment(VerticalAlignment.CENTER);

        CellStyle valueNumberStyle = wb.createCellStyle();
        valueNumberStyle.setFont(bodyFont);
        applyBorders(valueNumberStyle, BorderStyle.THIN);
        valueNumberStyle.setAlignment(HorizontalAlignment.RIGHT);
        valueNumberStyle.setVerticalAlignment(VerticalAlignment.CENTER);
        valueNumberStyle.setDataFormat(wb.getCreationHelper().createDataFormat().getFormat(NUMBER_FORMAT));

        Font grandTotalFont = wb.createFont();
        grandTotalFont.setBold(true);
        grandTotalFont.setFontName("Calibri");
        grandTotalFont.setFontHeightInPoints((short) 11);

        CellStyle grandTotalLabelStyle = wb.createCellStyle();
        grandTotalLabelStyle.setFont(grandTotalFont);
        applyBorders(grandTotalLabelStyle, BorderStyle.THIN);
        grandTotalLabelStyle.setAlignment(HorizontalAlignment.LEFT);
        grandTotalLabelStyle.setVerticalAlignment(VerticalAlignment.CENTER);
        grandTotalLabelStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        grandTotalLabelStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);

        CellStyle grandTotalNumberStyle = wb.createCellStyle();
        grandTotalNumberStyle.setFont(grandTotalFont);
        applyBorders(grandTotalNumberStyle, BorderStyle.THIN);
        grandTotalNumberStyle.setAlignment(HorizontalAlignment.RIGHT);
        grandTotalNumberStyle.setVerticalAlignment(VerticalAlignment.CENTER);
        grandTotalNumberStyle.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        grandTotalNumberStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        grandTotalNumberStyle.setDataFormat(wb.getCreationHelper().createDataFormat().getFormat(NUMBER_FORMAT));

        CellStyle dataIdStyle = wb.createCellStyle();
        dataIdStyle.setFont(bodyFont);
        applyBorders(dataIdStyle, BorderStyle.THIN);
        dataIdStyle.setAlignment(HorizontalAlignment.CENTER);
        dataIdStyle.setVerticalAlignment(VerticalAlignment.CENTER);

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

        return new Styles(
                titleStyle,
                darkBlueHeaderStyle,
                greenHeaderStyle,
                dataHeaderStyle,
                labelStyle,
                valueTextStyle,
                valueNumberStyle,
                grandTotalLabelStyle,
                grandTotalNumberStyle,
                dataIdStyle,
                dataDateStyle,
                dataTextStyle,
                dataRemarksStyle
        );
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

    private void setSummaryColumnWidths(Sheet sheet) {
        sheet.setColumnWidth(0, 16 * 256);
        sheet.setColumnWidth(1, 14 * 256);
        sheet.setColumnWidth(2, 3 * 256);
        sheet.setColumnWidth(3, 18 * 256);
        sheet.setColumnWidth(4, 14 * 256);
        sheet.setColumnWidth(5, 3 * 256);
        sheet.setColumnWidth(6, 14 * 256);
        sheet.setColumnWidth(7, 14 * 256);
        sheet.setColumnWidth(8, 14 * 256);
        sheet.setColumnWidth(9, 14 * 256);
        sheet.setColumnWidth(10, 12 * 256);
    }

    private void setDataColumnWidths(Sheet sheet) {
        sheet.setColumnWidth(0, 14 * 256);
        sheet.setColumnWidth(1, 14 * 256);
        sheet.setColumnWidth(2, 18 * 256);
        sheet.setColumnWidth(3, 24 * 256);
        sheet.setColumnWidth(4, 24 * 256);
        sheet.setColumnWidth(5, 32 * 256);
    }

    private record SummaryData(
            LocalDate fromDate,
            LocalDate toDate,
            int totalYears,
            int totalPurchases,
            int totalSuppliers,
            int totalCustomers,
            int totalStaff,
            TreeMap<Integer, YearAgg> byYear
    ) {}

    private static class YearAgg {
        private int purchases;
        private final Set<String> suppliers = new HashSet<>();
        private final Set<String> customers = new HashSet<>();
        private final Set<String> staff = new HashSet<>();
    }

    private record Styles(
            CellStyle titleStyle,
            CellStyle darkBlueHeaderStyle,
            CellStyle greenHeaderStyle,
            CellStyle dataHeaderStyle,
            CellStyle labelStyle,
            CellStyle valueTextStyle,
            CellStyle valueNumberStyle,
            CellStyle grandTotalLabelStyle,
            CellStyle grandTotalNumberStyle,
            CellStyle dataIdStyle,
            CellStyle dataDateStyle,
            CellStyle dataTextStyle,
            CellStyle dataRemarksStyle
    ) {}
}
