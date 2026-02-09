package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.BillEntryRequestDto;
import com.code.monks.csm.dto.request.BillUpdateRequest;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.*;
import com.code.monks.csm.exception.BillException;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.repository.BillEntryRepo;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.service.BillService;
import com.code.monks.csm.service.TransportService;
import com.code.monks.csm.service.file.FileUploadService;
import com.code.monks.csm.utils.ValidatorUtil;
import io.micrometer.common.util.StringUtils;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
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
    private final TransportService transportService;
    private final FileUploadService fileUploadService;

    @Transactional
    public BillEntryResponseDto addBill(BillEntryRequestDto requestDto, List<MultipartFile> images) {
        log.info("addBill() called with items: {}", requestDto);

        checkLrNumberDuplicate(requestDto.getLrNumber());

        String billNumber = generateBillNumber();
        log.debug("Generated bill number: {}", billNumber);
        String transportName = requestDto.getTransportName();
        try {
            BillEntryEntity billEntry = new BillEntryEntity();
            if (transportName != null && !transportName.trim().isEmpty()) {
                TransportEntity transport =
                        transportService.getOrCreateTransport(transportName.trim());
                billEntry.setTransportEntity(transport);
                log.debug("Transport set: {}", transportName);
            } else {
                billEntry.setTransportEntity(null);
                log.debug("No transport provided");
            }
            billEntry.setBillNumber(billNumber);
            billEntry.setDate(requestDto.getDate());
            billEntry.setReceivedDate(requestDto.getReceivedDate());
            billEntry.setOrders(requestDto.getOrder());
            billEntry.setSupplierId(requestDto.getSupplierId());
            billEntry.setCustomerId(requestDto.getCustomerId());
            billEntry.setLrNumber(requestDto.getLrNumber());
            billEntry.setRemarks(requestDto.getRemarks());
            billEntry.setTaxableValue(requestDto.getTaxableValue()*100);
            billEntry.setBillAmount(requestDto.getBillAmount()*100);

            List<BillDetailEntity> billItems = requestDto.getBillItems().stream()
                    .map(itemDto -> {
                        BillDetailEntity detail = new BillDetailEntity();
                        detail.setPieces(itemDto.getPieces());
                        detail.setGrossAmount((long) (itemDto.getGrossAmount() * 100));
                        detail.setDiscountPercent((int) itemDto.getDiscountPercent() * 100);
                        detail.setDiscountAmount((long) (itemDto.getDiscountAmount() * 100));
                        detail.setAddOnAmount((long) (itemDto.getAddOnAmount() * 100));
                        detail.setEcrAmount(itemDto.getEcrAmount() * 100);
                        detail.setGstPercent((int) itemDto.getGstPercent() * 100);
                        detail.setGstAmount((long) (itemDto.getGstAmount() * 100));
                        detail.setBillEntry(billEntry); // relation set
                        return detail;
                    })
                    .collect(Collectors.toList());
            billEntry.setBillDetails(billItems);

            //img upload
            if (images != null && !images.isEmpty()) {
                log.info("Uploading {} bill image(s)", images.size());
                List<String> imageUrls =
                        fileUploadService.uploadFiles(images);
                List<BillImageEntity> imageEntities = imageUrls.stream()
                        .map(url -> {
                            BillImageEntity image = new BillImageEntity();
                            image.setImageUrl(url);
                            image.setBillEntry(billEntry);
                            return image;
                        })
                        .collect(Collectors.toList());
                billEntry.setImages(imageEntities);
                log.info("Successfully uploaded {} image(s) for bill {}",
                        imageEntities.size(), billNumber);
            } else {
                log.info("No images provided for bill {}", billNumber);
            }


            billRepo.save(billEntry);
            log.info("Bill '{}' saved successfully with {} items", billNumber, billItems.size());

            return BillEntryResponseDto.builder()
                    .message("Bill added successfully: " + billNumber)
                    .build();

        } catch (BillException ex) {
            log.warn("Business rule violation: {}", ex.getMessage());
            throw ex;
        } catch (Exception ex) {
            log.error("Unexpected error while adding bill '{}'", billNumber, ex);
            throw new BillException(UNEXPECTED_EXCEPTION, "Failed to save bill");
        }
    }

    private void checkLrNumberDuplicate(String lrNumber) {
        if (StringUtils.isNotBlank(lrNumber) && billRepo.existsByLrNumber(lrNumber)) {
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
            throw new BillException(UNEXPECTED_EXCEPTION, " fetching bill entries");
        }
    }

    @Transactional
    @Override
    public EditBillEntryResponse updateBill(String billNumber, BillUpdateRequest request) {

        log.info("Update bill request started | billNumber={}", billNumber);
        BillEntryEntity bill = billRepo.findByBillNumber(billNumber)
                .orElseThrow(() -> {
                    log.error("Bill not found | billNumber={}", billNumber);
                    return new ResourceNotFoundException(BILL_NOT_FOUND, billNumber);
                });

        log.debug("Bill entity fetched | id={}", bill.getId());
            bill.setDate(LocalDate.parse(request.getDate()));
        Optional.ofNullable(request.getReceivedDate())
                .filter(date -> !date.trim().isEmpty())
                .map(LocalDate::parse)
                .ifPresent(bill::setReceivedDate);
        bill.setOrders(request.getOrder()); 
        bill.setSupplierId(request.getSupplierId());
        bill.setCustomerId(request.getCustomerId());


            if (request.getTransport() == null || request.getTransport().trim().isEmpty()) {
                bill.setTransportEntity(null);
            } else {
                String newName = request.getTransport().trim();
                TransportEntity transport = transportService
                        .findByNameIgnoreCase(newName)
                        .orElseThrow(() -> {
                            log.warn("⚠Transport not found | name={}", newName);
                            return new BillException(
                                    TRANSPORT_NOT_FOUND,
                                    "Transport does not exist: " + newName
                            );
                        });
                bill.setTransportEntity(transport);
                log.info("Transport linked | transportId={}, name={}",
                        transport.getId(), transport.getName());
            }

            bill.setLrNumber(request.getLrNumber());
            bill.setRemarks(request.getRemarks());

        bill.getBillDetails().forEach(d -> d.setBillEntry(null));
        bill.getBillDetails().clear();

        List<BillDetailEntity> newDetails = request.getBillItems().stream()
                .map(dto -> {
                    BillDetailEntity d = new BillDetailEntity();
                    d.setPieces(dto.getPieces());
                    d.setGrossAmount(Math.round(dto.getGrossAmount()) * 100);
                    d.setDiscountPercent(dto.getDiscountPercent() * 100);
                    d.setDiscountAmount(Math.round(dto.getDiscountAmount())  * 100);
                    d.setAddOnAmount(Math.round(dto.getAddOnAmount())  * 100);
                    d.setEcrAmount(Math.round(dto.getEcrAmount())  * 100);
                    d.setGstPercent(dto.getGstPercent()  * 100);
                    d.setGstAmount(Math.round(dto.getGstAmount())  * 100);
                    d.setBillEntry(bill);
                    return d;
                })
                .toList();

        bill.getBillDetails().addAll(newDetails);
        log.info("📦 Added new bill items | count={}", newDetails.size());

        // Header totals update
        bill.setTaxableValue(Math.round(request.getTaxableValue()) * 100);
        bill.setBillAmount(Math.round(request.getBillAmount()) * 100);

        log.debug(
                "Totals updated | taxableValue={}, billAmount={}",
                bill.getTaxableValue(),
                bill.getBillAmount()
        );

        billRepo.save(bill);

        log.info("Bill updated successfully | billNumber={}, billId={}",
                billNumber, bill.getId());

        return EditBillEntryResponse.builder()
                .message("Bill updated successfully!")
                .build();
    }

    @Override
    public PagedResponseDto<SearchBillEntryResponse> searchBillHistory(
            LocalDate fromDate,
            LocalDate toDate,
            Integer supplierId,
            Integer customerId,
            int page,
            int size) {

        log.info(
                "SearchBillHistory fromDate={}, toDate={}, supplierId={}, customerId={}, page={}, size={}",
                fromDate, toDate, supplierId, customerId, page, size
        );

        //STEP-1: Normalize dates
        LocalDate startDate =
                (fromDate != null) ? fromDate : LocalDate.of(1970, 1, 1);

        LocalDate endDate =
                (toDate != null) ? toDate : LocalDate.now();

        Pageable pageable = PageRequest.of(page, size, Sort.by("date", "id").descending()); // sorting by date desc
        Page<BillEntryEntity> billRecords;

        //Dynamic filter logic
        if (supplierId != null && customerId != null) {

            billRecords =
                    billRepo.findByDateBetweenAndSupplierIdAndCustomerId(
                            startDate, endDate, supplierId, customerId, pageable
                    );

        } else if (supplierId != null) {

            billRecords =
                    billRepo.findByDateBetweenAndSupplierId(
                            startDate, endDate, supplierId, pageable
                    );

        } else if (customerId != null) {

            billRecords =
                    billRepo.findByDateBetweenAndCustomerId(
                            startDate, endDate, customerId, pageable
                    );

        } else {

            billRecords =
                    billRepo.findByDateBetween(
                            startDate, endDate, pageable
                    );
        }

        List<SearchBillEntryResponse> content =
                billRecords.getContent()
                        .stream()
                        .map(this::convertToResponseDto)
                        .toList();

        return new PagedResponseDto<>(
                content,
                billRecords.getNumber(),
                billRecords.getSize(),
                billRecords.getTotalElements(),
                billRecords.getTotalPages(),
                billRecords.isLast()
        );
    }

    @Override
    public Map<String, Object> deleteBillEntry(String billNumber) {

        log.info("Delete request received for billNumber={}", billNumber);
        BillEntryEntity bill = billRepo.findByBillNumber(billNumber)
                .orElseThrow(() -> new ResourceNotFoundException(BILL_NOT_FOUND, billNumber));

        log.debug("Bill found with id={}, detailsCount={}, imagesCount={}",
                bill.getId(),
                bill.getBillDetails() != null ? bill.getBillDetails().size() : 0,
                bill.getImages() != null ? bill.getImages().size() : 0
        );

        billRepo.delete(bill);

        log.info("Bill deleted successfully for billNumber={}", billNumber);

        return Map.of(
                "message", "Bill deleted successfully",
                "billNumber", billNumber
        );
    }

    private SearchBillEntryResponse convertToResponseDto(BillEntryEntity entity) {
        CustomerEntity customerEntity = null;
        SupplierEntity supplierEntity = null;

        if (entity.getCustomerId() != null) {
            customerEntity = customerRepo.findById(entity.getCustomerId()).orElse(null);
        }

        if (entity.getSupplierId() != null) {
            supplierEntity = supplierRepo.findById(entity.getSupplierId()).orElse(null);
        }

        List<BillItemDto> itemDtos = entity.getBillDetails().stream()
                .map(detail -> BillItemDto.builder()
                        .pieces(detail.getPieces())
                        .grossAmount(detail.getGrossAmount()/100)
                        .discountPercent(detail.getDiscountPercent() /100)
                        .discountAmount(detail.getDiscountAmount()/100)
                        .addOnAmount(detail.getAddOnAmount()/100)
                        .ecrAmount(detail.getEcrAmount()/100)
                        .gstPercent(detail.getGstPercent()/ 100)
                        .gstAmount(detail.getGstAmount() / 100.0)
                        .build())
                .toList();

        String transportName = null;
        if (entity.getTransportEntity() != null) {
            transportName = entity.getTransportEntity().getName();
        }

        return SearchBillEntryResponse.builder()
                .billNumber(entity.getBillNumber())
                .date(entity.getDate())
                .receivedDate(entity.getReceivedDate())
                .order(entity.getOrders())
                .billAmount(entity.getBillAmount()/100)
                .taxableValue(entity.getTaxableValue()/100)
                .transport(transportName)
                .lrNumber(entity.getLrNumber())
                .remarks(entity.getRemarks())

                // Supplier
                .supplierId(supplierEntity != null ? supplierEntity.getId() : null)
                .supplierName(supplierEntity != null ? supplierEntity.getSupplierName() : null)
                .supplierGroup(supplierEntity != null ? supplierEntity.getGroupName() : null)
                .supplierGstNo(supplierEntity != null ? supplierEntity.getGstNo() : null)
                .supplierMsme(supplierEntity != null ? supplierEntity.getMsme() : null)

                // Customer
                .customerId(customerEntity != null ? customerEntity.getId() : null)
                .customerName(customerEntity != null ? customerEntity.getCustomerName() : null)
                .customerGroup(customerEntity != null ? customerEntity.getGroupName() : null)
                .customerGstNo(customerEntity != null ? customerEntity.getGstNo() : null)
                .customerMsme(customerEntity != null ? customerEntity.getMsme() : null)

                // Sabse important: items list
                .items(itemDtos)

                .build();
    }
}
