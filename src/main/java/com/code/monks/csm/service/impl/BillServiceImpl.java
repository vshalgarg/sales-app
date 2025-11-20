package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.BillEntryRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.BillEntryEntity;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.exception.BillException;
import com.code.monks.csm.exception.DuplicateEntryException;
import com.code.monks.csm.repository.BillEntryRepo;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.service.BillService;
import com.code.monks.csm.utils.ValidatorUtil;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static com.code.monks.csm.enums.ResponseErrorCode.*;

@Service
@AllArgsConstructor
@Slf4j
public class BillServiceImpl implements BillService {

    private final BillEntryRepo billRepo;

    private final ValidatorUtil validatorUtil;

    private final CustomerRepo customerRepo;

    private final SupplierRepo supplierRepo;

    public BillEntryResponseDto addBill(BillEntryRequestDto requestDto) {

        log.info("addBill() called...");
        checkLrNumberDuplicate(requestDto.getLrNumber());
        String billNumber = generateBillNumber();

        try {
            BillEntryEntity entity = BillEntryResponseDto.dtoToEntity(requestDto, billNumber);
            billRepo.save(entity);

            log.info("Bill '{}' saved successfully with ID: {}", billNumber, entity.getId());

            return BillEntryResponseDto.builder()
                    .message("Bill added successfully " + billNumber)
                    .build();

        } catch (BillException ex) {
            log.warn("Business rule violation while adding bill: {}", ex.getMessage());
            throw ex;
        } catch (Exception ex) {
            log.error("Unexpected error while adding bill '{}'", billNumber, ex);
            throw new BillException(UNEXPECTED_EXCEPTION, ex.getMessage());
        }
    }

    private void checkLrNumberDuplicate(String lrNumber) {
        if (lrNumber != null && billRepo.existsByLrNumber(lrNumber)) {
            log.warn("LR number already exists: {}", lrNumber);
            throw new BillException(DUPLICATE_ENTRY, "LR number already exists: " + lrNumber);
        }
    }


    private synchronized String generateBillNumber() {
        // 1️⃣ Fetch the last saved bill number from DB
        String lastBillNumber = billRepo.findTopByOrderByIdDesc()
                .map(BillEntryEntity::getBillNumber)
                .orElse(null);

        // 2️⃣ Extract the numeric part and increment
        int nextNumber = 1;
        if (lastBillNumber != null && lastBillNumber.startsWith("INV-")) {
            String numberPart = lastBillNumber.substring(4); // remove "INV-"
            try {
                nextNumber = Integer.parseInt(numberPart) + 1;
            } catch (NumberFormatException ignored) {
                nextNumber = 1;
            }
        }

        // 3️⃣ Format like INV-00001
        return String.format("INV-%05d", nextNumber);
    }


    private void validateBill(String billNumber) {
        List<ValidatorUtil.DuplicateCheck> duplicateChecks = new ArrayList<>();

        duplicateChecks.add(new ValidatorUtil.DuplicateCheck(
                "billNumber", () -> billRepo.existsByBillNumber(billNumber)
        ));
        validatorUtil.validateUniqueFields(duplicateChecks);
    }

    public List<GetBillEntries> getBillEntries() {
        log.info("Fetching all bill entries from database...");

        try {
            // Fetch all bills
            List<BillEntryEntity> bills = billRepo.findAll();
            log.info("Fetched {} bill entries from database", bills.size());

            // Map bill entries to DTO
            List<GetBillEntries> result = bills.stream().map(bill -> {
                GetBillEntries dto = GetBillEntries.convertToGetBillEntries(bill);

                CustomerEntity customerEntity = customerRepo.findById(bill.getCustomerId()).orElseThrow();
                dto.setCustomerName(customerEntity.getCustomerName());
                dto.setCustomerGroup(customerEntity.getGroupName());
                dto.setCustomerMsme(customerEntity.getMsme());
                dto.setCustomerGstNo(customerEntity.getGstNo());

                SupplierEntity supplierEntity = supplierRepo.findById(bill.getSupplierId()).orElseThrow();
                dto.setSupplierName(supplierEntity.getSupplierName());
                dto.setSupplierGroup(supplierEntity.getGroupName());
                dto.setSupplierMsme(supplierEntity.getMsme());
                dto.setSupplierGstNo(supplierEntity.getGstNo());

                return dto;
            }).toList();

            log.info("Successfully mapped {} bill entries with customer & supplier names", result.size());
            return result;

        } catch (DataAccessException dae) {
            log.error("Database access error while fetching bill entries", dae);
            throw new BillException(DATA_ACCESS_ERROR, dae.getMessage());
        } catch (Exception ex) {
            log.error("Unexpected error occurred while fetching bill entries", ex);
            throw new BillException(UNEXPECTED_EXCEPTION, ex.getMessage());
        }
    }

    @Transactional
    public EditBillEntryResponse updateBill(String billNumber, Map<String, Object> updates) {
        BillEntryEntity bill = billRepo.findByBillNumber(billNumber)
                .orElseThrow(() -> new RuntimeException("Bill not found"));

        updates.forEach((key, value) -> {
            switch (key) {
                case "supplierId" -> bill.setSupplierId((int) value);
                case "customerId" -> bill.setCustomerId((int) value);
                case "date" -> bill.setDate((LocalDate) value);
                case "receivedDate" -> bill.setReceivedDate((LocalDate) value);
                case "order" -> bill.setOrders((String) value);
                case "pieces" -> bill.setPieces((int) value);
                case "grossAmount" -> bill.setGrossAmount(Math.round((double) value)*100);
                case "discountPercent" -> bill.setDiscountPercent(Math.round((float) value)*100);
                case "discountAmount" -> bill.setDiscountAmount(Math.round((double) value)*100);
                case "addOnAmount" -> bill.setAddOnAmount(Math.round((double) value)*100);
                case "ecrAmount" -> bill.setEcrAmount(Math.round((double) value)*100);
                case "gstPercent" -> bill.setGstPercent(Math.round((float) value)*100);
                case "gstAmount" -> bill.setGstAmount(Math.round((double) value)*100);
                case "taxableValue" -> bill.setTaxableValue(Math.round((double) value)*100);
                case "billAmount" -> bill.setBillAmount(Math.round((double) value)*100);
                case "transport" -> bill.setTransport((String) value);
                case "lrNumber" -> bill.setLrNumber((String) value);
                case "remarks" -> bill.setRemarks((String) value);
                // add more cases for supported fields
                default -> throw new IllegalArgumentException("Unknown field: " + key);
            }
        });

        billRepo.save(bill);
        return EditBillEntryResponse.builder()
                .message("Bill changes are saved.")
                .build();
    }

    public PagedResponseDto<SearchBillEntryResponse> searchBillHistory(
            LocalDate fromDate,
            LocalDate toDate,
            String supplierName,
            String customerName,
            int page,
            int size) {

        log.info("SearchBillHistory called with fromDate={}, toDate={}, supplierName='{}', customerName='{}', page={}, size={}",
                fromDate, toDate, supplierName, customerName, page, size);

        Pageable pageable = PageRequest.of(page - 1, size, Sort.by("date").descending()); // sorting by date desc
        Page<BillEntryEntity> billRecords;

        Integer customerId = null;
        if (customerName != null && !customerName.isEmpty()) {
            CustomerEntity customerEntity = customerRepo.findByCustomerName(customerName);
            if (customerEntity != null) {
                customerId = customerEntity.getId();
                log.info("Customer entity found: {} with ID={}", customerEntity.getCustomerName(), customerId);
            } else {
                log.warn("No customer found with name '{}'", customerName);
            }
        } else {
            log.info("Customer name not provided");
        }

        Integer supplierId = null;
        if (supplierName != null && !supplierName.isEmpty()) {
            SupplierEntity supplierEntity = supplierRepo.findBySupplierName(supplierName);
            if (supplierEntity != null) {
                supplierId = supplierEntity.getId();
                log.info("Supplier entity found: {} with ID={}", supplierEntity.getSupplierName(), supplierId);
            } else {
                log.warn("No supplier found with name '{}'", supplierName);
            }
        } else {
            log.info("Supplier name not provided");
        }

        System.out.println("Resolved IDs -> Supplier ID: " + supplierId + ", Customer ID: " + customerId);

        // Determine which branch to take
        if (supplierId != null && customerId != null) {
            log.info("Fetching bills for both Supplier ID={} and Customer ID={}", supplierId, customerId);
            billRecords = billRepo.findByDateBetweenAndSupplierIdEqualsAndCustomerIdEquals(
                    fromDate, toDate, supplierId, customerId, pageable
            );
        } else if (supplierId != null) {
            log.info("Fetching bills for Supplier ID={}", supplierId);
            billRecords = billRepo.findByDateBetweenAndSupplierIdEquals(
                    fromDate, toDate, supplierId, pageable
            );
        } else if (customerId != null) {
            log.info("Fetching bills for Customer ID={}", customerId);
            billRecords = billRepo.findByDateBetweenAndCustomerIdEquals(
                    fromDate, toDate, customerId, pageable
            );
        } else {
            log.info("Fetching bills for all suppliers and customers");
            billRecords = billRepo.findByDateBetween(
                    fromDate, toDate, pageable
            );
        }

        log.info("Fetched {} bill records", billRecords.getTotalElements());

        // Convert entities to response DTOs
        List<SearchBillEntryResponse> content = billRecords.getContent()
                .stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());

        log.info("Returning page {} of {} (page size {}), isLast={}",
                billRecords.getNumber() + 1,
                billRecords.getTotalPages(),
                billRecords.getSize(),
                billRecords.isLast());

        return new PagedResponseDto<>(
                content,
                billRecords.getNumber() + 1,        // current page (1-based)
                billRecords.getSize(),              // page size
                billRecords.getTotalElements(),     // total records
                billRecords.getTotalPages(),        // total pages
                billRecords.isLast()                // last page?
        );
    }

    private SearchBillEntryResponse convertToResponseDto(BillEntryEntity entity) {
        CustomerEntity customerEntity = null;
        SupplierEntity supplierEntity = null;

        // ✅ Check if customerId exists
        if (entity.getCustomerId() != null) {
            customerEntity = customerRepo.findById(entity.getCustomerId())
                    .orElse(null);
        }

        // ✅ Check if supplierId exists
        if (entity.getSupplierId() != null) {
            supplierEntity = supplierRepo.findById(entity.getSupplierId())
                    .orElse(null);
        }

        return SearchBillEntryResponse.builder()
                .billNumber(entity.getBillNumber())
                .date(entity.getDate())
                .receivedDate(entity.getReceivedDate())
                .order(entity.getOrders())
                .pieces(entity.getPieces())
                .grossAmount(entity.getGrossAmount())
                .discountPercent((float) entity.getDiscountPercent())
                .discountAmount(entity.getDiscountAmount())
                .gstPercent((float) entity.getGstPercent())
                .gstAmount(entity.getGstAmount())
                .billAmount(entity.getBillAmount())
                .addOnAmount(entity.getAddOnAmount())
                .taxableValue(entity.getTaxableValue())
                .ecrAmount(entity.getEcrAmount())
                .transport(entity.getTransport())
                .lrNumber(entity.getLrNumber())
                .remarks(entity.getRemarks())

                // ✅ Only set fields if entity is present
                .supplierId(supplierEntity != null ? supplierEntity.getId() : null)
                .customerId(customerEntity != null ? customerEntity.getId() : null)
                .supplierName(supplierEntity != null ? supplierEntity.getSupplierName() : null)
                .customerName(customerEntity != null ? customerEntity.getCustomerName() : null)
                .supplierGstNo(supplierEntity != null ? supplierEntity.getGstNo() : null)
                .customerGstNo(customerEntity != null ? customerEntity.getGstNo() : null)
                .supplierGroup(supplierEntity != null ? supplierEntity.getGroupName() : null)
                .customerGroup(customerEntity != null ? customerEntity.getGroupName() : null)
                .supplierMsme(supplierEntity != null ? supplierEntity.getMsme() : null)
                .customerMsme(customerEntity != null ? customerEntity.getMsme() : null)
                .build();
    }


}
