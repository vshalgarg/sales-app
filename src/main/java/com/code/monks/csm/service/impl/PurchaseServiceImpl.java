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
import java.util.HashSet;
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

        log.info("Add Purchase Entry called with payload: {}", requestDto);
        PurchaseEntity entity = new PurchaseEntity();
        entity.setDate(requestDto.getDate());
        entity.setStaffId(requestDto.getStaffId());
        entity.setSupplierId(requestDto.getSupplierId());
        entity.setPurchaseAmount(
                requestDto.getPurchaseAmount() != null
                        ? Math.round(requestDto.getPurchaseAmount() * 100)
                        : null
        );

        if (requestDto.getCustomerIds() != null && !requestDto.getCustomerIds().isEmpty()) {
            entity.setCustomers(
                    new HashSet<>(customerRepo.findAllById(requestDto.getCustomerIds()))
            );
        }
        purchaseEntryRepo.save(entity);
        log.info("Purchase Entry saved successfully, id={}", entity.getId());
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
                        purchaseEntryRepo.findByDateBetweenAndSupplierIdAndCustomers_Id(
                                fromDate, toDate, supplierId, customerId, pageable
                        );

            } else if (supplierId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findByDateBetweenAndSupplierId(
                                fromDate, toDate, supplierId, pageable
                        );

            } else if (customerId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findByDateBetweenAndCustomers_Id(
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
                        purchaseEntryRepo.findBySupplierIdAndCustomers_Id(
                                supplierId, customerId, pageable
                        );

            } else if (supplierId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findBySupplierId(supplierId, pageable);

            } else if (customerId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findByCustomers_Id(customerId, pageable);

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

            if (req.getCustomerIds() != null) {
                entity.setCustomers(
                        new HashSet<>(customerRepo.findAllById(req.getCustomerIds()))
                );
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

        SupplierEntity supplier =
                entity.getSupplierId() != null
                        ? supplierRepo.findById(entity.getSupplierId()).orElse(null)
                        : null;

        StaffEntity staff =
                entity.getStaffId() != null
                        ? staffRepo.findById(entity.getStaffId()).orElse(null)
                        : null;

        return SearchPurchaseEntryResponse.builder()
                .id(entity.getId())
                .date(entity.getDate())
                .staffId(entity.getStaffId())
                .supplierId(entity.getSupplierId())
                .staffName(staff != null ? staff.getStaffName() : null)
                .supplierName(supplier != null ? supplier.getSupplierName() : null)
                .customerIds(
                        entity.getCustomers().stream()
                                .map(CustomerEntity::getId)
                                .toList()
                )
                .customerNames(
                        entity.getCustomers().stream()
                                .map(CustomerEntity::getCustomerName)
                                .toList()
                )
                .purchaseAmount(entity.getPurchaseAmount())
                .build();
    }

}
