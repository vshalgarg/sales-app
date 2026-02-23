package com.code.monks.csm.dataupload;

import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.PurchaseEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.PurchaseEntryRepo;
import com.code.monks.csm.repository.SupplierRepo;
import io.micrometer.common.util.StringUtils;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

@Slf4j
@Service
@AllArgsConstructor
public class XlsxReader {

    private CustomerRepo customerRepo;
    private SupplierRepo supplierRepo;
    private PurchaseEntryRepo purchaseEntryRepo;

    public List<ErrorDto> readXlsx(File file) {
        String customerName;
        List<String> supplierNameList = new ArrayList<>();
        LocalDate dateModified;
        try(
            FileInputStream fis = new FileInputStream(file);
            Workbook workbook = new XSSFWorkbook(fis);) {
            Sheet sheet = workbook.getSheetAt(0);

            dateModified = Instant.ofEpochMilli(file.lastModified())
                    .atZone(ZoneId.systemDefault())
                    .toLocalDate();

            Row firstRow = sheet.getRow(0);
            Cell firstCell = firstRow.getCell(0);
            customerName = firstCell.getStringCellValue();

            if(StringUtils.isBlank(customerName)) {
                return List.of(ErrorDto.builder().errorMessage("Customer name is empty")
                        .customerName(customerName).fileName(file.getName()).build());
            }

            boolean partySectionStarted = false;

            for (Row row : sheet) {
                Cell cell = row.getCell(1); // PARTY NAME column (Column B)

                if (cell != null && cell.getCellType() == CellType.STRING) {

                    String value = cell.getStringCellValue().trim();

                    // Detect header row
                    if (value.equalsIgnoreCase("PARTY NAME")) {
                        partySectionStarted = true;
                        continue;
                    }

                    // After header, read party names
                    if (partySectionStarted) {
                        if (value.isEmpty()) break; // stop when blank
                        supplierNameList.add(value);
                    }
                }
            }
            CustomerEntity customerEntity = null;
            try {
                List<CustomerEntity> customerEntities = customerRepo.findAllByCustomerNameIgnoreCase(customerName);
                if (customerEntities.isEmpty()) {
                    return List.of(ErrorDto.builder().errorMessage("Customer not found.")
                            .customerName(customerName).fileName(file.getName()).build());
                }
                if (customerEntities.size() > 1) {
                    return List.of(ErrorDto.builder().errorMessage("Multiple customers found.")
                            .customerName(customerName).fileName(file.getName()).build());
                }
                customerEntity = customerEntities.get(0);
            } catch (Exception ex) {
                return List.of(ErrorDto.builder().errorMessage("Unexpected error while finding customer")
                        .customerName(customerName).fileName(file.getName()).build());
            }
            List<ErrorDto> errorDtoList = new ArrayList<>();
            for(String supplierName : supplierNameList) {
                try {
                    List<SupplierEntity> supplierEntity = supplierRepo.findAllBySupplierNameIgnoreCase(supplierName);
                    if (supplierEntity.isEmpty()) {
                        errorDtoList.add(ErrorDto.builder().errorMessage("Supplier not found.")
                                .customerName(customerName)
                                .supplierName(supplierName).fileName(file.getName()).build());
                        continue;
                    }
                    if (supplierEntity.size() > 1) {
                        errorDtoList.add(ErrorDto.builder().errorMessage("Multiple suppliers found.")
                                .customerName(customerName).supplierName(supplierName).fileName(file.getName()).build());
                        continue;
                    }
                    PurchaseEntity purchaseEntity = new PurchaseEntity();
                    purchaseEntity.setDate(dateModified);
                    purchaseEntity.setCustomers(Set.of(customerEntity));
                    purchaseEntity.setSupplierId(supplierEntity.get(0).getId());
                    purchaseEntryRepo.save(purchaseEntity);
                } catch (Exception e) {
                    errorDtoList.add(ErrorDto.builder().errorMessage("Unexpected error while processing supplier.")
                            .customerName(customerName).supplierName(supplierName).fileName(file.getName()).build());
                }
            }
            return errorDtoList;
        } catch (FileNotFoundException ex) {
            log.error(ex.getMessage(), ex);
            return List.of(ErrorDto.builder().errorMessage("File Not found")
                    .fileName(file.getName()).build());
        } catch (IOException ex) {
            log.error(ex.getMessage(), ex);
            return List.of(ErrorDto.builder().errorMessage("Error opening the file")
                    .fileName(file.getName()).build());
        }
    }
}
