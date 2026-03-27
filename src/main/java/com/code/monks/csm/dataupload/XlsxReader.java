package com.code.monks.csm.dataupload;

import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.PurchaseEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.PurchaseEntryRepo;
import com.code.monks.csm.repository.SupplierRepo;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
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

            Path path = file.toPath();
            BasicFileAttributes attr = Files.readAttributes(path, BasicFileAttributes.class);

            dateModified = Instant.ofEpochMilli(file.lastModified())
                    .atZone(ZoneId.systemDefault())
                    .toLocalDate();

            Row firstRow = sheet.getRow(0);
            Cell firstCell = firstRow.getCell(0);
            customerName = firstCell.getStringCellValue();

            String customerGstNo = null;

            for(Row row : sheet) {
                Cell cell = row.getCell(0);
                String cellValue = cell.getStringCellValue();
                if(StringUtils.isNotBlank(cellValue) && StringUtils.containsIgnoreCase(cellValue, "gst")) {
                    String[] splittedCellValue = cellValue.split(" ");
                    customerGstNo = splittedCellValue[splittedCellValue.length - 1].trim();
                    break;
                }
            }
            String finalGstNo = customerGstNo;

            if(StringUtils.isBlank(customerName)) {
                return List.of(ErrorDto.builder().errorMessage("Customer name is empty")
                        .customerName(customerName).gstNo(customerGstNo).fileName(file.getName()).build());
            }


            CustomerEntity customerEntity = null;
            try {
                //first find by name only
                List<CustomerEntity> customerEntities = customerRepo.findAllByCustomerNameIgnoreCase(customerName);
                //3 possible cases
                if(CollectionUtils.isEmpty(customerEntities)) {
                    //if no record found we need to fetch by gst no.
                    List<CustomerEntity> gstCustomerEntities = customerRepo.findAllByGstNoContainingIgnoreCase(finalGstNo);
                    if(CollectionUtils.isEmpty(gstCustomerEntities)) {
                        if (gstCustomerEntities.isEmpty()) {
                            return List.of(ErrorDto.builder().errorMessage("Customer Not found, Customer not found.")
                                    .customerName(customerName).gstNo(finalGstNo).fileName(file.getName()).build());
                        }
                        if(gstCustomerEntities.size() > 1) {
                            return List.of(ErrorDto.builder().errorMessage("Customer Not found, Multiple Customers found.")
                                    .customerName(customerName).gstNo(finalGstNo).fileName(file.getName()).build());
                        }
                        customerEntity = gstCustomerEntities.get(0);
                    }
                } else if(customerEntities.size() == 1) {
                    //if one record found, it is our data
                    customerEntity = customerEntities.get(0);
                } else {
                    //if multiple records found, filter via gst No
                    if(StringUtils.isNotBlank(finalGstNo)) {
                        List<CustomerEntity> filteredCustomerEntities = customerEntities.stream().filter(e -> e.getGstNo().contains(finalGstNo)).toList();
                        if (filteredCustomerEntities.isEmpty()) {
                            return List.of(ErrorDto.builder().errorMessage("Multiple customers found, Customer not found.")
                                    .customerName(customerName).gstNo(finalGstNo).fileName(file.getName()).build());
                        }
                        if (customerEntities.size() > 1) {
                            return List.of(ErrorDto.builder().errorMessage("Multiple customers found, Multiple Customers found.")
                                    .customerName(customerName).gstNo(finalGstNo).fileName(file.getName()).build());
                        }
                        customerEntity = filteredCustomerEntities.get(0);
                    }
                }
            } catch (Exception ex) {
                return List.of(ErrorDto.builder().errorMessage("Unexpected error while finding customer")
                        .customerName(customerName).gstNo(finalGstNo).fileName(file.getName()).build());
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
            List<ErrorDto> errorDtoList = new ArrayList<>();
            for(String supplierName : supplierNameList) {
                try {
                    List<SupplierEntity> supplierEntity = supplierRepo.findAllBySupplierNameIgnoreCase(supplierName);
                    if (supplierEntity.isEmpty()) {
                        errorDtoList.add(ErrorDto.builder().errorMessage("Supplier not found.")
                                .customerName(customerName).gstNo(finalGstNo)
                                .supplierName(supplierName).fileName(file.getName()).build());
                    }else if (supplierEntity.size() > 1) {
                        errorDtoList.add(ErrorDto.builder().errorMessage("Multiple suppliers found.")
                                .customerName(customerName).gstNo(finalGstNo).supplierName(supplierName).fileName(file.getName()).build());
                    }else {
                        log.info("inserting: {},  {}", customerName, supplierName);
                    }
                } catch (Exception e) {
                    errorDtoList.add(ErrorDto.builder().errorMessage("Unexpected error while processing supplier.")
                            .customerName(customerName).gstNo(finalGstNo).supplierName(supplierName).fileName(file.getName()).build());
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
