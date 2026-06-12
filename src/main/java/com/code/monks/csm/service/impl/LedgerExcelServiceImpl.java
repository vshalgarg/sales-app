package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.ledger.LedgerEntryDto;
import com.code.monks.csm.dto.ledger.LedgerResponseDto;
import com.code.monks.csm.service.LedgerExcelService;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Service
@Slf4j
public class LedgerExcelServiceImpl implements LedgerExcelService {

    private static final String DATE_FORMAT = "dd-MM-yyyy";
    private static final String NUMBER_FORMAT = "#,##0.00";
    private static final int TABLE_COLUMNS = 6;
    private static final int PARTY_CARD_START_COL = 1;
    private static final int PARTY_CARD_END_COL = 4;
    private static final int SUMMARY_COL = 4;

    @Override
    public byte[] generateExcel(LedgerResponseDto ledger) {
        int entryCount = ledger.entries().size();
        log.info("Starting Excel generation for ledger: party={}, type={}, entries={}",
                ledger.party().name(), ledger.ledgerType(), entryCount);

        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            Sheet sheet = workbook.createSheet("Ledger");

            CellStyle titleStyle = createTitleStyle(workbook);
            CellStyle generatedDateStyle = createGeneratedDateStyle(workbook);
            CellStyle cardLabelStyle = createCardLabelStyle(workbook);
            CellStyle cardValueStyle = createCardValueStyle(workbook);
            CellStyle cardNameValueStyle = createCardNameValueStyle(workbook);
            CellStyle sectionHeadingStyle = createSectionHeadingStyle(workbook);
            CellStyle headerStyle = createHeaderStyle(workbook);
            CellStyle headerFirstStyle = createHeaderEdgeStyle(workbook, true);
            CellStyle headerLastStyle = createHeaderEdgeStyle(workbook, false);
            CellStyle dateStyle = createDateCellStyle(workbook);
            CellStyle textStyle = createTextCellStyle(workbook);
            CellStyle amountStyle = createAmountCellStyle(workbook);
            CellStyle evenDateStyle = createEvenRowStyle(workbook, dateStyle);
            CellStyle evenTextStyle = createEvenRowStyle(workbook, textStyle);
            CellStyle evenAmountStyle = createEvenRowStyle(workbook, amountStyle);
            CellStyle balHighlightStyle = createBalanceHighlightStyle(workbook, false);
            CellStyle evenBalHighlightStyle = createBalanceHighlightStyle(workbook, true);
            CellStyle summaryHeaderStyle = createSummaryHeaderStyle(workbook);
            CellStyle summaryLabelStyle = createSummaryLabelStyle(workbook, false);
            CellStyle summaryValueStyle = createSummaryValueStyle(workbook, false);
            CellStyle summaryClosingLabelStyle = createSummaryLabelStyle(workbook, true);
            CellStyle summaryClosingValueStyle = createSummaryValueStyle(workbook, true);
            CellStyle lastDataDateStyle = createLastDataCellStyle(workbook, dateStyle, false);
            CellStyle lastDataTextStyle = createLastDataCellStyle(workbook, textStyle, false);
            CellStyle lastDataAmountStyle = createLastDataCellStyle(workbook, amountStyle, false);
            CellStyle lastDataEvenDateStyle = createLastDataCellStyle(workbook, evenDateStyle, true);
            CellStyle lastDataEvenTextStyle = createLastDataCellStyle(workbook, evenTextStyle, true);
            CellStyle lastDataEvenAmountStyle = createLastDataCellStyle(workbook, evenAmountStyle, true);
            CellStyle lastDataBalStyle = createLastDataCellStyle(workbook, balHighlightStyle, false);
            CellStyle lastDataEvenBalStyle = createLastDataCellStyle(workbook, evenBalHighlightStyle, true);

            int rowNum = 0;

            writeTitle(sheet, rowNum++, titleStyle);
            writeGeneratedDate(sheet, rowNum++, generatedDateStyle);
            rowNum++;
            rowNum = writePartyCard(sheet, rowNum, ledger, cardLabelStyle, cardValueStyle, cardNameValueStyle);
            rowNum++;
            rowNum = writeSectionHeading(sheet, rowNum, sectionHeadingStyle);
            rowNum++;

            int headerRowNum = rowNum;
            log.debug("Table header row number: {}", headerRowNum);
            writeTableHeader(sheet, rowNum, headerStyle, headerFirstStyle, headerLastStyle);
            rowNum++;
            int firstDataRowNum = rowNum;
            log.debug("First data row number: {}", firstDataRowNum);
            boolean lastRowIsEven = (entryCount > 0) && (entryCount % 2 == 0);
            rowNum = writeEntryRows(sheet, rowNum, ledger,
                    dateStyle, textStyle, amountStyle, balHighlightStyle,
                    evenDateStyle, evenTextStyle, evenAmountStyle, evenBalHighlightStyle,
                    lastDataDateStyle, lastDataTextStyle, lastDataAmountStyle, lastDataBalStyle,
                    lastDataEvenDateStyle, lastDataEvenTextStyle, lastDataEvenAmountStyle, lastDataEvenBalStyle,
                    lastRowIsEven);
            log.debug("Last entry written, final rowNum={}", rowNum);

            int summaryRow = rowNum + 2;
            writeSummaryBox(sheet, summaryRow, SUMMARY_COL, ledger,
                    summaryHeaderStyle, summaryLabelStyle, summaryValueStyle,
                    summaryClosingLabelStyle, summaryClosingValueStyle);

            setColumnWidths(sheet);
            sheet.createFreezePane(0, headerRowNum);
            sheet.setFitToPage(true);
            sheet.setPrintGridlines(false);

            workbook.write(out);
            byte[] result = out.toByteArray();
            log.info("Excel generated successfully. entries={}, headerRow={}, firstDataRow={}, finalRow={}, size={} bytes",
                    entryCount, headerRowNum, firstDataRowNum, rowNum, result.length);
            return result;

        } catch (Exception e) {
            log.error("Failed to generate Excel for ledger: party={}, type={}",
                    ledger.party().name(), ledger.ledgerType(), e);
            throw new RuntimeException("Failed to generate ledger Excel file", e);
        }
    }

    private void writeTitle(Sheet sheet, int rowNum, CellStyle style) {
        Row row = sheet.createRow(rowNum);
        row.setHeightInPoints(30);
        for (int i = 0; i < TABLE_COLUMNS; i++) {
            Cell cell = row.createCell(i);
            if (i == 0) {
                cell.setCellValue("LEDGER REPORT");
            }
            cell.setCellStyle(style);
        }
        sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, 0, TABLE_COLUMNS - 1));
    }

    private void writeGeneratedDate(Sheet sheet, int rowNum, CellStyle style) {
        Row row = sheet.createRow(rowNum);
        String dateText = "Generated On: " + LocalDate.now().format(DateTimeFormatter.ofPattern(DATE_FORMAT));
        for (int i = 0; i < TABLE_COLUMNS; i++) {
            Cell cell = row.createCell(i);
            if (i == 0) {
                cell.setCellValue(dateText);
            }
            cell.setCellStyle(style);
        }
        sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, 0, TABLE_COLUMNS - 1));
    }

    private int writePartyCard(Sheet sheet, int rowNum, LedgerResponseDto ledger,
                                CellStyle labelStyle, CellStyle valueStyle, CellStyle nameValueStyle) {
        int cardWidth = PARTY_CARD_END_COL - PARTY_CARD_START_COL;

        String[][] fields = {
                {"Party Name", ledger.party().name()},
                {"Phone", ledger.party().phone() != null ? ledger.party().phone() : "-"},
                {"Email", ledger.party().email() != null ? ledger.party().email() : "-"},
                {"Address", ledger.party().address() != null ? ledger.party().address() : "-"},
                {"Ledger Type", ledger.ledgerType().name()}
        };

        for (int f = 0; f < fields.length; f++) {
            Row row = sheet.createRow(rowNum++);
            boolean isNameRow = (f == 0);

            Cell labelCell = row.createCell(PARTY_CARD_START_COL);
            labelCell.setCellValue(fields[f][0]);
            labelCell.setCellStyle(labelStyle);

            Cell valueCell = row.createCell(PARTY_CARD_START_COL + 1);
            valueCell.setCellValue(fields[f][1]);
            valueCell.setCellStyle(isNameRow ? nameValueStyle : valueStyle);

            if (cardWidth > 1) {
                for (int i = PARTY_CARD_START_COL + 2; i <= PARTY_CARD_END_COL; i++) {
                    Cell fillCell = row.createCell(i);
                    fillCell.setCellStyle(isNameRow ? nameValueStyle : valueStyle);
                }
                sheet.addMergedRegion(new CellRangeAddress(
                        rowNum - 1, rowNum - 1,
                        PARTY_CARD_START_COL + 1, PARTY_CARD_END_COL
                ));
            }
        }

        return rowNum;
    }

    private int writeSectionHeading(Sheet sheet, int rowNum, CellStyle style) {
        Row row = sheet.createRow(rowNum);
        row.setHeightInPoints(20);
        for (int i = 0; i < TABLE_COLUMNS; i++) {
            Cell cell = row.createCell(i);
            if (i == 0) {
                cell.setCellValue("Transaction Details");
            }
            cell.setCellStyle(style);
        }
        sheet.addMergedRegion(new CellRangeAddress(rowNum, rowNum, 0, TABLE_COLUMNS - 1));
        return rowNum + 1;
    }

    private void writeTableHeader(Sheet sheet, int rowNum, CellStyle midStyle,
                                   CellStyle firstStyle, CellStyle lastStyle) {
        Row row = sheet.createRow(rowNum);
        row.setHeightInPoints(24);
        String[] headers = {"Date", "Invoice No", "Particular", "Debit", "Credit", "Running Balance"};
        for (int i = 0; i < headers.length; i++) {
            Cell cell = row.createCell(i);
            cell.setCellValue(headers[i]);
            if (i == 0) {
                cell.setCellStyle(firstStyle);
            } else if (i == headers.length - 1) {
                cell.setCellStyle(lastStyle);
            } else {
                cell.setCellStyle(midStyle);
            }
        }
    }

    private int writeEntryRows(Sheet sheet, int rowNum, LedgerResponseDto ledger,
                                CellStyle dateStyle, CellStyle textStyle, CellStyle amountStyle,
                                CellStyle balStyle,
                                CellStyle evenDateStyle, CellStyle evenTextStyle, CellStyle evenAmountStyle,
                                CellStyle evenBalStyle,
                                CellStyle lastDateStyle, CellStyle lastTextStyle, CellStyle lastAmountStyle,
                                CellStyle lastBalStyle,
                                CellStyle lastEvenDateStyle, CellStyle lastEvenTextStyle,
                                CellStyle lastEvenAmountStyle, CellStyle lastEvenBalStyle,
                                boolean lastRowIsEven) {
        int entryCount = ledger.entries().size();
        boolean isEven = false;
        int idx = 0;
        for (LedgerEntryDto entry : ledger.entries()) {
            boolean isLastRow = (idx == entryCount - 1);
            Row row = sheet.createRow(rowNum);

            CellStyle csDate, csText, csAmount, csBal;
            if (isLastRow) {
                csDate = lastRowIsEven ? lastEvenDateStyle : lastDateStyle;
                csText = lastRowIsEven ? lastEvenTextStyle : lastTextStyle;
                csAmount = lastRowIsEven ? lastEvenAmountStyle : lastAmountStyle;
                csBal = lastRowIsEven ? lastEvenBalStyle : lastBalStyle;
            } else {
                csDate = isEven ? evenDateStyle : dateStyle;
                csText = isEven ? evenTextStyle : textStyle;
                csAmount = isEven ? evenAmountStyle : amountStyle;
                csBal = isEven ? evenBalStyle : balStyle;
            }

            Cell dateCell = row.createCell(0);
            dateCell.setCellValue(entry.date());
            dateCell.setCellStyle(csDate);

            Cell invCell = row.createCell(1);
            invCell.setCellValue(entry.invoiceNo());
            invCell.setCellStyle(csText);

            Cell partCell = row.createCell(2);
            partCell.setCellValue(entry.particular());
            partCell.setCellStyle(csText);

            Cell debitCell = row.createCell(3);
            debitCell.setCellValue(entry.debit().doubleValue());
            debitCell.setCellStyle(csAmount);

            Cell creditCell = row.createCell(4);
            creditCell.setCellValue(entry.credit().doubleValue());
            creditCell.setCellStyle(csAmount);

            Cell balCell = row.createCell(5);
            balCell.setCellValue(entry.runningBalance().doubleValue());
            balCell.setCellStyle(csBal);

            rowNum++;
            isEven = !isEven;
            idx++;
        }
        return rowNum;
    }

    private void writeSummaryBox(Sheet sheet, int startRow, int startCol, LedgerResponseDto ledger,
                                  CellStyle headerStyle, CellStyle labelStyle, CellStyle valueStyle,
                                  CellStyle closingLabelStyle, CellStyle closingValueStyle) {
        String[] labels = {"Total Debit", "Total Credit", "Closing Balance"};
        double[] values = {
                ledger.totalDebit().doubleValue(),
                ledger.totalCredit().doubleValue(),
                ledger.balance().doubleValue()
        };

        int r = startRow;

        Row headerRow = sheet.createRow(r);
        Cell sHeader = headerRow.createCell(startCol);
        sHeader.setCellValue("SUMMARY");
        sHeader.setCellStyle(headerStyle);
        headerRow.createCell(startCol + 1).setCellStyle(headerStyle);
        sheet.addMergedRegion(new CellRangeAddress(r, r, startCol, startCol + 1));
        r++;

        for (int i = 0; i < labels.length; i++) {
            Row row = sheet.createRow(r);
            boolean isClosing = (i == labels.length - 1);

            Cell label = row.createCell(startCol);
            label.setCellValue(labels[i]);
            label.setCellStyle(isClosing ? closingLabelStyle : labelStyle);

            Cell value = row.createCell(startCol + 1);
            value.setCellValue(values[i]);
            value.setCellStyle(isClosing ? closingValueStyle : valueStyle);

            r++;
        }
    }

    private CellStyle createTitleStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 18);
        font.setColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    private CellStyle createGeneratedDateStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setFontHeightInPoints((short) 10);
        font.setColor(IndexedColors.GREY_50_PERCENT.getIndex());
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    private CellStyle createCardLabelStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 10);
        style.setFont(font);
        applyBorders(style, BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.RIGHT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return style;
    }

    private CellStyle createCardValueStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setFontHeightInPoints((short) 10);
        style.setFont(font);
        applyBorders(style, BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    private CellStyle createCardNameValueStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 12);
        style.setFont(font);
        applyBorders(style, BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    private CellStyle createSectionHeadingStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        font.setColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFont(font);
        style.setAlignment(HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.BOTTOM);
        style.setBorderBottom(BorderStyle.THIN);
        return style;
    }

    private CellStyle createHeaderStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        font.setColor(IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderTop(BorderStyle.MEDIUM);
        style.setBorderBottom(BorderStyle.MEDIUM);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    private CellStyle createHeaderEdgeStyle(Workbook wb, boolean isFirst) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        font.setColor(IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderTop(BorderStyle.MEDIUM);
        style.setBorderBottom(BorderStyle.MEDIUM);
        style.setBorderLeft(isFirst ? BorderStyle.MEDIUM : BorderStyle.THIN);
        style.setBorderRight(isFirst ? BorderStyle.THIN : BorderStyle.MEDIUM);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    private CellStyle createDateCellStyle(Workbook wb) {
        CellStyle style = baseCellStyle(wb);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setDataFormat(wb.getCreationHelper().createDataFormat().getFormat(DATE_FORMAT));
        return style;
    }

    private CellStyle createTextCellStyle(Workbook wb) {
        CellStyle style = baseCellStyle(wb);
        style.setAlignment(HorizontalAlignment.LEFT);
        return style;
    }

    private CellStyle createAmountCellStyle(Workbook wb) {
        CellStyle style = baseCellStyle(wb);
        style.setAlignment(HorizontalAlignment.RIGHT);
        style.setDataFormat(wb.getCreationHelper().createDataFormat().getFormat(NUMBER_FORMAT));
        return style;
    }

    private CellStyle createBalanceHighlightStyle(Workbook wb, boolean isEven) {
        CellStyle style = baseCellStyle(wb);
        style.setAlignment(HorizontalAlignment.RIGHT);
        style.setDataFormat(wb.getCreationHelper().createDataFormat().getFormat(NUMBER_FORMAT));
        style.setFillForegroundColor(isEven
                ? IndexedColors.LIGHT_CORNFLOWER_BLUE.getIndex()
                : IndexedColors.LIGHT_TURQUOISE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return style;
    }

    private CellStyle createEvenRowStyle(Workbook wb, CellStyle base) {
        CellStyle style = wb.createCellStyle();
        style.cloneStyleFrom(base);
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        return style;
    }

    private CellStyle createLastDataCellStyle(Workbook wb, CellStyle base, boolean isEven) {
        CellStyle style = wb.createCellStyle();
        style.cloneStyleFrom(base);
        style.setBorderBottom(BorderStyle.MEDIUM);
        if (isEven) {
            style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
            style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        }
        return style;
    }

    private CellStyle createSummaryHeaderStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 11);
        font.setColor(IndexedColors.WHITE.getIndex());
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setBorderTop(BorderStyle.MEDIUM);
        style.setBorderBottom(BorderStyle.MEDIUM);
        style.setBorderLeft(BorderStyle.MEDIUM);
        style.setBorderRight(BorderStyle.MEDIUM);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    private CellStyle createSummaryLabelStyle(Workbook wb, boolean isClosing) {
        CellStyle style = wb.createCellStyle();
        Font font = wb.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 10);
        style.setFont(font);
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.MEDIUM);
        style.setBorderRight(BorderStyle.THIN);
        style.setAlignment(HorizontalAlignment.LEFT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        if (isClosing) {
            style.setFillForegroundColor(IndexedColors.LEMON_CHIFFON.getIndex());
            style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        }
        return style;
    }

    private CellStyle createSummaryValueStyle(Workbook wb, boolean isClosing) {
        CellStyle style = wb.createCellStyle();
        if (isClosing) {
            Font font = wb.createFont();
            font.setBold(true);
            font.setFontHeightInPoints((short) 10);
            style.setFont(font);
        }
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.MEDIUM);
        style.setAlignment(HorizontalAlignment.RIGHT);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        style.setDataFormat(wb.getCreationHelper().createDataFormat().getFormat(NUMBER_FORMAT));
        if (isClosing) {
            style.setFillForegroundColor(IndexedColors.LEMON_CHIFFON.getIndex());
            style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        }
        return style;
    }

    private CellStyle baseCellStyle(Workbook wb) {
        CellStyle style = wb.createCellStyle();
        style.setBorderTop(BorderStyle.THIN);
        style.setBorderBottom(BorderStyle.THIN);
        style.setBorderLeft(BorderStyle.THIN);
        style.setBorderRight(BorderStyle.THIN);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        return style;
    }

    private void applyBorders(CellStyle style, BorderStyle border) {
        style.setBorderTop(border);
        style.setBorderBottom(border);
        style.setBorderLeft(border);
        style.setBorderRight(border);
    }

    private void setColumnWidths(Sheet sheet) {
        sheet.setColumnWidth(0, 14 * 256);
        sheet.setColumnWidth(1, 16 * 256);
        sheet.setColumnWidth(2, 22 * 256);
        sheet.setColumnWidth(3, 14 * 256);
        sheet.setColumnWidth(4, 14 * 256);
        sheet.setColumnWidth(5, 18 * 256);
    }
}
