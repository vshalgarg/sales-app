package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.dto.request.UpdatePurchaseEntryReq;
import com.code.monks.csm.dto.response.AddPurchaseEntryResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.SearchPurchaseEntryResponse;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.PurchaseEntity;
import com.code.monks.csm.entity.StaffEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.exception.ResourceNotFoundException;
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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.code.monks.csm.enums.ResponseErrorCode.PURCHASE_ENTRY_NOT_FOUND;

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
            int size)   {

        int pageIndex = Math.max(page, 0);
        Pageable pageable = PageRequest.of(pageIndex, size, Sort.by("date").descending());
        Page<PurchaseEntity> purchaseRecords;
        log.info("Purchase search called: fromDate={}, toDate={}, supplierId={}, customerId={}",
                fromDate, toDate, supplierId, customerId);

        if (fromDate != null && toDate != null) {

            if (supplierId != null && customerId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findByDateBetweenAndSupplierIdAndCustomerId(
                                fromDate, toDate, supplierId, customerId, pageable
                        );

            } else if (supplierId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findByDateBetweenAndSupplierId(
                                fromDate, toDate, supplierId, pageable
                        );

            } else if (customerId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findByDateBetweenAndCustomerId(
                                fromDate, toDate, customerId, pageable
                        );

            } else {
                purchaseRecords =
                        purchaseEntryRepo.findByDateBetween(fromDate, toDate, pageable);
            }

        } else {
            // NO DATE FILTER
            if (supplierId != null && customerId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findBySupplierIdAndCustomerId(
                                supplierId, customerId, pageable
                        );

            } else if (supplierId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findBySupplierId(supplierId, pageable);

            } else if (customerId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findByCustomerId(customerId, pageable);

            } else {
                purchaseRecords =
                        purchaseEntryRepo.findAll(pageable);
            }
        }

        List<SearchPurchaseEntryResponse> content =
                purchaseRecords.getContent()
                        .stream()
                        .map(this::convertToResponseDto)
                        .toList();

        return new PagedResponseDto<>(
                content,
                purchaseRecords.getNumber(),
                purchaseRecords.getSize(),
                purchaseRecords.getTotalElements(),
                purchaseRecords.getTotalPages(),
                purchaseRecords.isLast()
        );
    }

        @Override
        public Map<String, Object> updatePurchaseEntry(int id, UpdatePurchaseEntryReq req) {
            log.info(" Update Purchase Entry called for ID={}", id);
            PurchaseEntity entity = purchaseEntryRepo.findById(id)
                    .orElseThrow(() ->
                            new ResourceNotFoundException(PURCHASE_ENTRY_NOT_FOUND,": "+ id)
                    );

            if (req.getDate() != null) {
                entity.setDate(req.getDate());
            }

            if (req.getStaffId() != null) {
                entity.setStaffId(req.getStaffId());
            }

            if (req.getSupplierId() != null) {
                entity.setSupplierId(req.getSupplierId());
            }

            if (req.getCustomerId() != null) {
                entity.setCustomerId(req.getCustomerId());
            }
            entity.setPurchaseAmount(req.getPurchaseAmount());
            PurchaseEntity updated = purchaseEntryRepo.save(entity);
            log.info("Purchase Entry updated successfully. ID={}", updated.getId());

            Map<String, Object> response = new HashMap<>();
            response.put("message", "Purchase entry updated successfully");
            response.put("id", updated.getId());
            return response;
        }

    @Override
    public Map<String, Object> deletePurchaseEntry(int id) {

        log.info(" Delete Purchase Entry called for ID={}", id);
        PurchaseEntity entity = purchaseEntryRepo.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(PURCHASE_ENTRY_NOT_FOUND,": "+ id)
                );
        purchaseEntryRepo.delete(entity);
        log.info("Purchase Entry deleted successfully. ID={}", id);

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Purchase entry deleted successfully");
        response.put("id", id);
        return response;
    }

    private SearchPurchaseEntryResponse convertToResponseDto(PurchaseEntity entity) {

        log.info("Converting PurchaseEntity ID={}", entity.getId());

        CustomerEntity customer = null;
        SupplierEntity supplier = null;
        StaffEntity staff = null;

        if (entity.getCustomerId() > 0) {
            customer = customerRepo.findById(entity.getCustomerId()).orElse(null);
        }

        if (entity.getSupplierId() > 0) {
            supplier = supplierRepo.findById(entity.getSupplierId()).orElse(null);
        }

        if (entity.getStaffId() > 0) {
            staff = staffRepo.findById(entity.getStaffId()).orElse(null);
        }

        return SearchPurchaseEntryResponse.builder()
                .id(entity.getId())
                .date(entity.getDate())

                .staffId(entity.getStaffId())
                .supplierId(entity.getSupplierId())
                .customerId(entity.getCustomerId())

                .staffName(staff != null ? staff.getStaffName() : null)
                .supplierName(supplier != null ? supplier.getSupplierName() : null)
                .customerName(customer != null ? customer.getCustomerName() : null)

                .purchaseAmount(entity.getPurchaseAmount())
                .build();
    }

}
