package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.ledger.LedgerEntryDto;
import com.code.monks.csm.dto.ledger.LedgerResponseDto;
import com.code.monks.csm.enums.ResponseErrorCode;
import com.code.monks.csm.exception.ExcelGenerationException;
import com.code.monks.csm.service.LedgerExcelService;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;
import org.apache.poi.xssf.usermodel.XSSFColor;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@Slf4j
public class LedgerExcelServiceImpl implements LedgerExcelService {

    private static final String DATE_FORMAT   = "dd-MM-yyyy";
    private static final String NUMBER_FORMAT = "#,##0.00";
    private static final int TABLE_COLUMNS       = 6;
    private static final int PARTY_CARD_START_COL = 1;
    private static final int PARTY_CARD_END_COL   = 5;

    private static final byte[] HEADER_BLUE = {(byte) 68, (byte) 114, (byte) 196};

    @Override
    public byte[] generateExcel(LedgerResponseDto ledger) {
        int entryCount = ledger.entries().size();
        log.info("Generating ledger Excel: party={}, type={}, entries={}",
                ledger.party().name(), ledger.ledgerType(), entryCount);

        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("Ledger");

            CellStyle titleStyle          = createTitleStyle(workbook);
            CellStyle genDateStyle        = createGeneratedDateStyle(workbook);
            CellStyle cardLabelStyle      = createCardLabelStyle(workbook);
            CellStyle cardValueStyle      = createCardValueStyle(workbook);
            CellStyle cardNameValueStyle  = createCardNameValueStyle(workbook);
            CellStyle sectionStyle        = createSectionHeadingStyle(workbook);
            CellStyle headerStyle         = createHeaderStyle(workbook);
            CellStyle headerFirstStyle    = createHeaderEdgeStyle(workbook, true);
            CellStyle headerLastStyle     = createHeaderEdgeStyle(workbook, false);
            CellStyle dateStyle           = createDateCellStyle(workbook);
            CellStyle textStyle           = createTextCellStyle(workbook);
            CellStyle amountStyle         = createAmountCellStyle(workbook);
            CellStyle evenDateStyle       = dateStyle;
            CellStyle evenTextStyle       = textStyle;
            CellStyle evenAmountStyle     = amountStyle;
            CellStyle totalLabelStyle     = createTotalRowLabelStyle(workbook);
            CellStyle totalAmountStyle    = createTotalRowAmountStyle(workbook);

            CellStyle lastDateStyle       = addMediumBottomBorder(workbook, dateStyle);
            CellStyle lastTextStyle       = addMediumBottomBorder(workbook, textStyle);
            CellStyle lastAmountStyle     = addMediumBottomBorder(workbook, amountStyle);
            CellStyle lastEvenDateStyle   = addMediumBottomBorder(workbook, evenDateStyle);
            CellStyle lastEvenTextStyle   = addMediumBottomBorder(workbook, evenTextStyle);
            CellStyle lastEvenAmountStyle = addMediumBottomBorder(workbook, evenAmountStyle);

            int rowNum = 0;

            writeTitle(sheet, rowNum++, titleStyle);
            writeGeneratedDate(sheet, rowNum++, genDateStyle);
            rowNum++;
            rowNum = writeSectionHeading(sheet, rowNum, sectionStyle, "Party Information", PARTY_CARD_START_COL);
            rowNum = writePartyCard(sheet, rowNum, ledger, cardLabelStyle, cardValueStyle, cardNameValueStyle);
            rowNum++;
            rowNum = writeSectionHeading(sheet, rowNum, sectionStyle, "Transaction Details", 0);

            writeTableHeader(sheet, rowNum, headerStyle, headerFirstStyle, headerLastStyle);
            rowNum++;

            rowNum = writeEntryRows(sheet, rowNum, ledger,
                    dateStyle, textStyle, amountStyle,
                    evenDateStyle, evenTextStyle, evenAmountStyle,
                    lastDateStyle, lastTextStyle, lastAmountStyle,
                    lastEvenDateStyle, lastEvenTextStyle, lastEvenAmountStyle);

            writeTotalRow(sheet, rowNum, ledger, totalLabelStyle, totalAmountStyle);

            setColumnWidths(sheet);
            //sheet.createFreezePane(0, headerRowNum + 1);
            sheet.setFitToPage(true);
            sheet.setPrintGridlines(false);

            workbook.write(out);
            byte[] result = out.toByteArray();
            log.info("Excel generated: entries={}, size={} bytes", entryCount, result.length);
            return result;

        } catch (Exception e) {
            throw new ExcelGenerationException(ResponseErrorCode.EXCEL_GENERATION_FAILED, e);
        }
    }

    // ─── Section Writers ─────────────────────────────────────────────────────────

    private void writeTitle(Sheet sheet, int rowNum, CellStyle style) {
        Row row = sheet.createRow(rowNum);
        row.setHeightInPoints(32);
        for (int i = 0; i < TABLE_COLUMNS; i++) {
            Cell cell = row.createCell(i);
            if (i == 0) cell.setCellValue("LEDGER REPORT");
            cell.setCellStyle(style);
        }
        sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, 0, TABLE_COLUMNS - 1));
    }

    private void writeGeneratedDate(Sheet sheet, int rowNum, CellStyle style) {
        Row row = sheet.createRow(rowNum);
        row.setHeightInPoints(18);
        String text = "Generated On: " + LocalDate.now().format(DateTimeFormatter.ofPattern(DATE_FORMAT));
        for (int i = 0; i < TABLE_COLUMNS; i++) {
            Cell cell = row.createCell(i);
            if (i == 0) cell.setCellValue(text);
            cell.setCellStyle(style);
        }
        sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, 0, TABLE_COLUMNS - 1));
    }

    private int writeSectionHeading(Sheet sheet, int rowNum, CellStyle style, String heading, int startCol) {
        Row row = sheet.createRow(rowNum);
        row.setHeightInPoints(20);
        for (int i = startCol; i < TABLE_COLUMNS; i++) {
            Cell cell = row.createCell(i);
            if (i == startCol) cell.setCellValue(heading);
            cell.setCellStyle(style);
        }
        sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, startCol, TABLE_COLUMNS - 1));
        return rowNum + 1;
    }

    private int writePartyCard(Sheet sheet, int rowNum, LedgerResponseDto ledger,
                               CellStyle labelStyle, CellStyle valueStyle, CellStyle nameValueStyle) {
        String[][] fields = {
                {"Party Name",  ledger.party().name()},
                {"Phone",       ledger.party().phone()   != null ? ledger.party().phone()   : "-"},
                {"Email",       ledger.party().email()   != null ? ledger.party().email()   : "-"},
                {"Address",     ledger.party().address() != null ? ledger.party().address() : "-"},
                {"Ledger Type", ledger.ledgerType().name()}
        };

        for (int f = 0; f < fields.length; f++) {
            Row row = sheet.createRow(rowNum++);
            boolean isName = (f == 0);

            Cell label = row.createCell(PARTY_CARD_START_COL);
            label.setCellValue(fields[f][0]);
            label.setCellStyle(labelStyle);

            Cell value = row.createCell(PARTY_CARD_START_COL + 1);
            value.setCellValue(fields[f][1]);
            value.setCellStyle(isName ? nameValueStyle : valueStyle);

            for (int i = PARTY_CARD_START_COL + 2; i <= PARTY_CARD_END_COL; i++) {
                row.createCell(i).setCellStyle(isName ? nameValueStyle : valueStyle);
            }
            sheet.addMergedRegion(new CellRangeAddress(
                    rowNum - 1, rowNum - 1, PARTY_CARD_START_COL + 1, PARTY_CARD_END_COL));
        }
        return rowNum;
    }

    private void writeTableHeader(Sheet sheet, int rowNum, CellStyle midStyle,
                                  CellStyle firstStyle, CellStyle lastStyle) {
        Row row = sheet.createRow(rowNum);
        row.setHeightInPoints(24);
        String[] headers = {"Date", "Invoice No", "Particular", "Debit", "Credit", "Running Balance"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = row.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(i == 0 ? firstStyle : i == headers.length - 1 ? lastStyle : midStyle);
        }
    }

    private int writeEntryRows(Sheet sheet, int rowNum, LedgerResponseDto ledger,
                               CellStyle dateStyle,     CellStyle textStyle,     CellStyle amountStyle,
                               CellStyle evenDateStyle, CellStyle evenTextStyle, CellStyle evenAmountStyle,
                               CellStyle lastDateStyle,     CellStyle lastTextStyle,     CellStyle lastAmountStyle,
                               CellStyle lastEvenDateStyle, CellStyle lastEvenTextStyle, CellStyle lastEvenAmountStyle) {
        List<LedgerEntryDto> entries = ledger.entries().stream()
                .filter(e -> e != null && e.particular() != null && !e.particular().isBlank())
                .toList();
        boolean isEven = false;
        for (int i = 0; i < entries.size(); i++) {
            LedgerEntryDto e  = entries.get(i);
            boolean last      = (i == entries.size() - 1);
            Row row           = sheet.createRow(rowNum);

            CellStyle csDate, csText, csAmt;
            if (last && isEven)  { csDate = lastEvenDateStyle; csText = lastEvenTextStyle; csAmt = lastEvenAmountStyle; }
            else if (last)       { csDate = lastDateStyle;     csText = lastTextStyle;     csAmt = lastAmountStyle; }
            else if (isEven)     { csDate = evenDateStyle;     csText = evenTextStyle;     csAmt = evenAmountStyle; }
            else                 { csDate = dateStyle;         csText = textStyle;         csAmt = amountStyle; }

            row.createCell(0).setCellValue(e.date());                      row.getCell(0).setCellStyle(csDate);
            row.createCell(1).setCellValue(e.invoiceNo());                 row.getCell(1).setCellStyle(csText);
            row.createCell(2).setCellValue(e.particular());                row.getCell(2).setCellStyle(csText);
            row.createCell(3).setCellValue(e.debit().doubleValue());       row.getCell(3).setCellStyle(csAmt);
            row.createCell(4).setCellValue(e.credit().doubleValue());      row.getCell(4).setCellStyle(csAmt);
            row.createCell(5).setCellValue(e.runningBalance().doubleValue()); row.getCell(5).setCellStyle(csAmt);

            rowNum++;
            isEven = !isEven;
        }
        return rowNum;
    }

    private void writeTotalRow(Sheet sheet, int rowNum, LedgerResponseDto ledger,
                               CellStyle labelStyle, CellStyle amountStyle) {
        Row row = sheet.createRow(rowNum);
        row.setHeightInPoints(20);

        for (int i = 0; i < 3; i++) {
            Cell cell = row.createCell(i);
            if (i == 0) cell.setCellValue("Total");
            cell.setCellStyle(labelStyle);
        }
        sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, 0, 2));

        row.createCell(3).setCellValue(ledger.totalDebit().doubleValue());   row.getCell(3).setCellStyle(amountStyle);
        row.createCell(4).setCellValue(ledger.totalCredit().doubleValue());  row.getCell(4).setCellStyle(amountStyle);
        row.createCell(5).setCellValue(ledger.balance().doubleValue());      row.getCell(5).setCellStyle(amountStyle);
    }

    // ─── Style Helpers ────────────────────────────────────────────────────────────

    private XSSFColor headerBlue() {
        return new XSSFColor(HEADER_BLUE, null);
    }

    private CellStyle addMediumBottomBorder(Workbook wb, CellStyle base) {
        CellStyle s = wb.createCellStyle();
        s.cloneStyleFrom(base);
        s.setBorderBottom(BorderStyle.MEDIUM);
        return s;
    }

    private CellStyle createTitleStyle(Workbook wb) {
        XSSFCellStyle s = (XSSFCellStyle) wb.createCellStyle();
        Font f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 20);
        f.setColor(IndexedColors.WHITE.getIndex());
        s.setFont(f);
        s.setAlignment(HorizontalAlignment.CENTER);
        s.setVerticalAlignment(VerticalAlignment.CENTER);
        s.setFillForegroundColor(headerBlue());
        s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return s;
    }

    private CellStyle createGeneratedDateStyle(Workbook wb) {
        XSSFCellStyle s = (XSSFCellStyle) wb.createCellStyle();
        Font f = wb.createFont();
        f.setFontHeightInPoints((short) 10);
        f.setColor(IndexedColors.WHITE.getIndex());
        s.setFont(f);
        s.setAlignment(HorizontalAlignment.CENTER);
        s.setVerticalAlignment(VerticalAlignment.CENTER);
        s.setFillForegroundColor(headerBlue());
        s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return s;
    }

    private CellStyle createCardLabelStyle(Workbook wb) {
        CellStyle s = wb.createCellStyle();
        Font f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 10);
        s.setFont(f);
        applyBorders(s, BorderStyle.THIN);
        s.setAlignment(HorizontalAlignment.RIGHT);
        s.setVerticalAlignment(VerticalAlignment.CENTER);
        s.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return s;
    }

    private CellStyle createCardValueStyle(Workbook wb) {
        CellStyle s = wb.createCellStyle();
        Font f = wb.createFont();
        f.setFontHeightInPoints((short) 10);
        s.setFont(f);
        applyBorders(s, BorderStyle.THIN);
        s.setAlignment(HorizontalAlignment.LEFT);
        s.setVerticalAlignment(VerticalAlignment.CENTER);
        s.setWrapText(true);
        return s;
    }

    private CellStyle createCardNameValueStyle(Workbook wb) {
        CellStyle s = wb.createCellStyle();
        Font f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 12);
        s.setFont(f);
        applyBorders(s, BorderStyle.THIN);
        s.setAlignment(HorizontalAlignment.LEFT);
        s.setVerticalAlignment(VerticalAlignment.CENTER);
        return s;
    }

    private CellStyle createSectionHeadingStyle(Workbook wb) {
        XSSFCellStyle s = (XSSFCellStyle) wb.createCellStyle();
        Font f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 12);
        f.setColor(IndexedColors.WHITE.getIndex());
        s.setFont(f);
        s.setAlignment(HorizontalAlignment.CENTER);
        s.setVerticalAlignment(VerticalAlignment.CENTER);
        s.setFillForegroundColor(headerBlue());
        s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return s;
    }

    private CellStyle createHeaderStyle(Workbook wb) {
        XSSFCellStyle s = (XSSFCellStyle) wb.createCellStyle();
        Font f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 11);
        f.setColor(IndexedColors.WHITE.getIndex());
        s.setFont(f);
        s.setFillForegroundColor(headerBlue());
        s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        s.setBorderTop(BorderStyle.MEDIUM);
        s.setBorderBottom(BorderStyle.MEDIUM);
        s.setBorderLeft(BorderStyle.THIN);
        s.setBorderRight(BorderStyle.THIN);
        s.setAlignment(HorizontalAlignment.CENTER);
        s.setVerticalAlignment(VerticalAlignment.CENTER);
        return s;
    }

    private CellStyle createHeaderEdgeStyle(Workbook wb, boolean isFirst) {
        XSSFCellStyle s = (XSSFCellStyle) wb.createCellStyle();
        Font f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 11);
        f.setColor(IndexedColors.WHITE.getIndex());
        s.setFont(f);
        s.setFillForegroundColor(headerBlue());
        s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        s.setBorderTop(BorderStyle.MEDIUM);
        s.setBorderBottom(BorderStyle.MEDIUM);
        s.setBorderLeft(isFirst ? BorderStyle.MEDIUM : BorderStyle.THIN);
        s.setBorderRight(isFirst ? BorderStyle.THIN   : BorderStyle.MEDIUM);
        s.setAlignment(HorizontalAlignment.CENTER);
        s.setVerticalAlignment(VerticalAlignment.CENTER);
        return s;
    }

    private CellStyle createDateCellStyle(Workbook wb) {
        CellStyle s = baseCellStyle(wb);
        s.setAlignment(HorizontalAlignment.CENTER);
        s.setDataFormat(wb.getCreationHelper().createDataFormat().getFormat(DATE_FORMAT));
        return s;
    }

    private CellStyle createTextCellStyle(Workbook wb) {
        CellStyle s = baseCellStyle(wb);
        s.setAlignment(HorizontalAlignment.LEFT);
        return s;
    }

    private CellStyle createAmountCellStyle(Workbook wb) {
        CellStyle s = baseCellStyle(wb);
        s.setAlignment(HorizontalAlignment.RIGHT);
        s.setDataFormat(wb.getCreationHelper().createDataFormat().getFormat(NUMBER_FORMAT));
        return s;
    }


    private CellStyle createTotalRowLabelStyle(Workbook wb) {
        CellStyle s = wb.createCellStyle();
        Font f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 10);
        s.setFont(f);
        s.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        s.setBorderTop(BorderStyle.MEDIUM);
        s.setBorderBottom(BorderStyle.MEDIUM);
        s.setBorderLeft(BorderStyle.MEDIUM);
        s.setBorderRight(BorderStyle.THIN);
        s.setAlignment(HorizontalAlignment.LEFT);
        s.setVerticalAlignment(VerticalAlignment.CENTER);
        return s;
    }

    private CellStyle createTotalRowAmountStyle(Workbook wb) {
        CellStyle s = wb.createCellStyle();
        Font f = wb.createFont();
        f.setBold(true);
        f.setFontHeightInPoints((short) 10);
        s.setFont(f);
        s.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        s.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        s.setBorderTop(BorderStyle.MEDIUM);
        s.setBorderBottom(BorderStyle.MEDIUM);
        s.setBorderLeft(BorderStyle.THIN);
        s.setBorderRight(BorderStyle.MEDIUM);
        s.setAlignment(HorizontalAlignment.RIGHT);
        s.setVerticalAlignment(VerticalAlignment.CENTER);
        s.setDataFormat(wb.getCreationHelper().createDataFormat().getFormat(NUMBER_FORMAT));
        return s;
    }

    private CellStyle baseCellStyle(Workbook wb) {
        CellStyle s = wb.createCellStyle();
        s.setBorderTop(BorderStyle.THIN);
        s.setBorderBottom(BorderStyle.THIN);
        s.setBorderLeft(BorderStyle.THIN);
        s.setBorderRight(BorderStyle.THIN);
        s.setVerticalAlignment(VerticalAlignment.CENTER);
        return s;
    }

    private void applyBorders(CellStyle s, BorderStyle border) {
        s.setBorderTop(border);
        s.setBorderBottom(border);
        s.setBorderLeft(border);
        s.setBorderRight(border);
    }

    private void setColumnWidths(Sheet sheet) {
        sheet.setColumnWidth(0, 13 * 256);
        sheet.setColumnWidth(1, 18 * 256);
        sheet.setColumnWidth(2, 24 * 256);
        sheet.setColumnWidth(3, 15 * 256);
        sheet.setColumnWidth(4, 15 * 256);
        sheet.setColumnWidth(5, 18 * 256);
    }
}
