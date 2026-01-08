package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.dto.response.AddPurchaseEntryResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.SearchCreditEntryResponse;
import com.code.monks.csm.dto.response.SearchPurchaseEntryResponse;
import com.code.monks.csm.entity.*;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.PurchaseEntryRepo;
import com.code.monks.csm.repository.StaffRepo;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.service.PurchaseService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
@Slf4j
public class PurchaseServiceImpl implements PurchaseService {

    private final PurchaseEntryRepo purchaseEntryRepo;

    private final CustomerRepo customerRepo;

    private final SupplierRepo supplierRepo;

    private final StaffRepo staffRepo;

    public AddPurchaseEntryResponseDto addPurchaseEntry(AddPurchaseEntryRequestDto requestDto){
        PurchaseEntity entity = AddPurchaseEntryResponseDto.dtoToEntity(requestDto);
        purchaseEntryRepo.save(entity);
        return AddPurchaseEntryResponseDto.builder()
                .message("Purchase entry saved successfully")
                .build();
    }

    public PagedResponseDto<SearchPurchaseEntryResponse> searchPurchaseHistory(
            LocalDate fromDate,
            LocalDate toDate,
            Integer supplierId,
            Integer customerId,
            int page,
            int size) {

        log.info("➡️ searchPurchaseHistory() called with: fromDate={}, toDate={}, supplierId={}, customerId={}, page={}, size={}",
                fromDate, toDate, supplierId, customerId, page, size);

        // ✅ Adjust page index (PageRequest is 0-based)
        int pageIndex = Math.max(page, 0);
        Pageable pageable = PageRequest.of(pageIndex, size, Sort.by("date").descending());
        Page<PurchaseEntity> purchaseRecords;

        try {
            // ✅ Filtering logic with logs
            if (supplierId != null && customerId != null) {
                log.info("📦 Fetching purchase entries for Supplier ID={} and Customer ID={}", supplierId, customerId);
                purchaseRecords = purchaseEntryRepo.findByDateBetweenAndSupplierIdEqualsAndCustomerIdEquals(
                        fromDate, toDate, supplierId, customerId, pageable
                );
            } else if (supplierId != null) {
                log.info("📦 Fetching purchase entries for Supplier ID={}", supplierId);
                purchaseRecords = purchaseEntryRepo.findByDateBetweenAndSupplierIdEquals(
                        fromDate, toDate, supplierId, pageable
                );
            } else if (customerId != null) {
                log.info("📦 Fetching purchase entries for Customer ID={}", customerId);
                purchaseRecords = purchaseEntryRepo.findByDateBetweenAndCustomerIdEquals(
                        fromDate, toDate, customerId, pageable
                );
            } else {
                log.info("📦 Fetching all purchase entries (no supplier or customer filter)");
                purchaseRecords = purchaseEntryRepo.findByDateBetween(fromDate, toDate, pageable);
                System.out.println("This is record : "+purchaseRecords.getContent());
            }

            log.info("✅ Fetched {} purchase records (page {}/{})",
                    purchaseRecords.getNumber(),
                    purchaseRecords.getTotalPages(),
                    purchaseRecords.getTotalElements()
            );

            // ✅ Map entities to response DTOs
            List<SearchPurchaseEntryResponse> content = purchaseRecords.getContent()
                    .stream()
                    .map(this::convertToResponseDto)
                    .collect(Collectors.toList());

            log.info("✅ Successfully converted {} purchase records into response DTOs", content.size());

            return new PagedResponseDto<>(
                    content,
                    purchaseRecords.getNumber(),
                    purchaseRecords.getSize(),
                    purchaseRecords.getTotalElements(),
                    purchaseRecords.getTotalPages(),
                    purchaseRecords.isLast()
            );

        } catch (Exception e) {
            log.error("❌ Exception in searchPurchaseHistory(): {}", e.getMessage(), e);
            throw e; // rethrow for controller advice or global handler
        }
    }

    private SearchPurchaseEntryResponse convertToResponseDto(PurchaseEntity entity) {
        log.info("🔄 Starting conversion for PurchaseEntity ID={}", entity.getId());

        CustomerEntity customerEntity = null;
        SupplierEntity supplierEntity = null;
        StaffEntity staffEntity = null;

        try {
            // Fetch Customer
            if (entity.getCustomerId() > 0) {
                log.debug("Fetching CustomerEntity for ID={}", entity.getCustomerId());
                customerEntity = customerRepo.findById(entity.getCustomerId()).orElse(null);
                log.info("✅ Customer lookup result for ID={}: {}",
                        entity.getCustomerId(),
                        customerEntity != null ? customerEntity.getCustomerName() : "NOT FOUND");
            } else {
                log.debug("No Customer ID found for PurchaseEntity ID={}", entity.getId());
            }

            // Fetch Supplier
            if (entity.getSupplierId() > 0) {
                log.debug("Fetching SupplierEntity for ID={}", entity.getSupplierId());
                supplierEntity = supplierRepo.findById(entity.getSupplierId()).orElse(null);
                log.info("✅ Supplier lookup result for ID={}: {}",
                        entity.getSupplierId(),
                        supplierEntity != null ? supplierEntity.getSupplierName() : "NOT FOUND");
            } else {
                log.debug("No Supplier ID found for PurchaseEntity ID={}", entity.getId());
            }


            if (entity.getStaffId() > 0) {
                log.debug("Fetching StaffEntity for ID={}", entity.getStaffId());
                log.info("Fetching StaffEntity for ID={}", entity.getStaffId());
                staffEntity = staffRepo.findById(entity.getStaffId()).orElse(null);
                log.info("✅ Staff lookup result for ID={}: {}",
                        entity.getStaffId(),
                        staffEntity != null ? staffEntity.getStaffName() : "NOT FOUND");
            } else {
                log.debug("No Staff ID found for PurchaseEntity ID={}", entity.getId());
            }
//            if (entity.getStaffId() > 0) {
//                log.info("🧩 Fetching StaffEntity for staffId={}", entity.getStaffId());
//                try {
//                    staffEntity = staffRepo.findById(entity.getStaffId()).orElse(null);
//
//                    if (staffEntity != null) {
//                        log.info("✅ Found StaffEntity: ID={} | Name={}",
//                                staffEntity.getId(), staffEntity.getStaffName());
//                    } else {
//                        log.warn("⚠️ No StaffEntity found for ID={}", entity.getStaffId());
//                    }
//                } catch (Exception ex) {
//                    log.error("❌ Error fetching StaffEntity for ID={} : {}",
//                            entity.getStaffId(), ex.getMessage(), ex);
//                }
//            } else {
//                log.warn("⚠️ PurchaseEntity ID={} has invalid staffId={}",
//                        entity.getId(), entity.getStaffId());
//            }

//            if (entity.getStaffId() > 0) {
//                log.info("🧩 Fetching StaffEntity for staffId={}", entity.getStaffId());
//
//                if (staffRepo.existsById(entity.getStaffId())) {
//                    staffEntity = staffRepo.findById(entity.getStaffId()).orElse(null);
//                    log.info("✅ Found StaffEntity: {}", staffEntity.getStaffName());
//                } else {
//                    log.warn("⚠️ No StaffEntity exists for ID={}", entity.getStaffId());
//                }
//            } else {
//                log.debug("No Staff ID found for PurchaseEntity ID={}", entity.getId());
//            }

            // Build Response DTO
            SearchPurchaseEntryResponse response = SearchPurchaseEntryResponse.builder()
                    .id(entity.getId())
                    .date(entity.getDate())
                    .staffName(staffEntity != null ? staffEntity.getStaffName() : "N/A")
                    .supplierName(supplierEntity != null ? supplierEntity.getSupplierName() : "N/A")
                    .customerName(customerEntity != null ? customerEntity.getCustomerName() : "N/A")
                    .purchaseAmount(entity.getPurchaseAmount())
                    .build();

            log.info("✅ Successfully converted PurchaseEntity ID={} -> Response DTO", entity.getId());
            log.debug("Response DTO details: {}", response);

            return response;

        } catch (Exception e) {
            log.error("❌ Error while converting PurchaseEntity ID={} : {}", entity.getId(), e.getMessage(), e);
            throw e;
        }
    }


}
