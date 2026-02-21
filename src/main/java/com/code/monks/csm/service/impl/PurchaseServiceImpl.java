package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.dto.request.UpdatePurchaseEntryReq;
import com.code.monks.csm.dto.response.AddPurchaseEntryResponseDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.SearchPurchaseEntryResponse;
import com.code.monks.csm.entity.*;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.PurchaseEntryRepo;
import com.code.monks.csm.repository.StaffRepo;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.service.PurchaseService;
import com.code.monks.csm.service.file.FileUploadService;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

import static com.code.monks.csm.enums.ResponseErrorCode.*;

@Service
@AllArgsConstructor
@Slf4j
public class PurchaseServiceImpl implements PurchaseService {

    private final PurchaseEntryRepo purchaseEntryRepo;
    private final CustomerRepo customerRepo;
    private final SupplierRepo supplierRepo;
    private final StaffRepo staffRepo;
    private final FileUploadService fileUploadService;

    private static final String MODULE = "orderForm";

    @Override
    @Transactional
    public AddPurchaseEntryResponseDto addPurchaseEntry(
            AddPurchaseEntryRequestDto requestDto,
            List<MultipartFile> images
    ) {

        PurchaseEntity entity = new PurchaseEntity();

        applyRequestToEntity(
                entity,
                requestDto.getDate(),
                requestDto.getStaffId(),
                requestDto.getSupplierIds(),
                requestDto.getCustomerId(),
                requestDto.getPurchaseAmount()
        );

        handleImages(entity, images);

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
        Pageable pageable = PageRequest.of(
                pageIndex,
                size,
                Sort.by(
                        Sort.Order.desc("date"),
                        Sort.Order.desc("id")
                )
        );
        Page<PurchaseEntity> purchaseRecords;
        log.info("Purchase search called: fromDate={}, toDate={}, supplierId={}, customerId={}",
                fromDate, toDate, supplierId, customerId);

        if (fromDate != null && toDate != null) {

            if (supplierId != null && customerId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findByDateBetweenAndSuppliers_IdAndCustomer_Id(
                                fromDate, toDate, supplierId, customerId, pageable
                        );

            } else if (supplierId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findByDateBetweenAndSuppliers_Id(
                                fromDate, toDate, supplierId, pageable
                        );

            } else if (customerId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findByDateBetweenAndCustomer_Id(
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
                        purchaseEntryRepo.findBySuppliers_IdAndCustomer_Id(
                                supplierId, customerId, pageable
                        );

            } else if (supplierId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findBySuppliers_Id(supplierId, pageable);

            } else if (customerId != null) {
                purchaseRecords =
                        purchaseEntryRepo.findByCustomer_Id(customerId, pageable);

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
    @Transactional
    public Map<String, Object> updatePurchaseEntry(int id, UpdatePurchaseEntryReq req) {

        log.info("Update Purchase Entry called for ID={}", id);

        PurchaseEntity entity = purchaseEntryRepo.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                PURCHASE_ENTRY_NOT_FOUND,
                                String.valueOf(id)
                        )
                );

        applyRequestToEntity(
                entity,
                req.getDate(),
                req.getStaffId(),
                req.getSupplierIds(),
                req.getCustomerId(),
                req.getPurchaseAmount()
        );

        PurchaseEntity updated = purchaseEntryRepo.save(entity);

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

        StaffEntity staff =
                entity.getStaffId() != null
                        ? staffRepo.findById(entity.getStaffId()).orElse(null)
                        : null;

        return SearchPurchaseEntryResponse.builder()
                .id(entity.getId())
                .date(entity.getDate())
                .staffId(entity.getStaffId())
                .staffName(staff != null ? staff.getStaffName() : null)

                .supplierIds(
                        entity.getSuppliers().stream()
                                .map(SupplierEntity::getId)
                                .toList()
                )
                .supplierNames(
                        entity.getSuppliers().stream()
                                .map(SupplierEntity::getSupplierName)
                                .toList()
                )

                .customerId(
                        entity.getCustomer() != null
                                ? entity.getCustomer().getId()
                                : null
                )
                .customerName(
                        entity.getCustomer() != null
                                ? entity.getCustomer().getCustomerName()
                                : null
                )

                .purchaseAmount(
                        entity.getPurchaseAmount() != null
                                ? entity.getPurchaseAmount() / 100.0
                                : 0.0
                )
                .build();
    }
    private void applyRequestToEntity(
            PurchaseEntity entity,
            LocalDate date,
            Integer staffId,
            List<Integer> supplierIds,
            Integer customerId,
            Double purchaseAmount
    ) {

        if (date != null) {
            entity.setDate(date);
        }

        if (staffId != null) {
            entity.setStaffId(staffId);
        }

        if (purchaseAmount != null) {
            entity.setPurchaseAmount(Math.round(purchaseAmount * 100));
        }

        if (supplierIds != null) {

            List<SupplierEntity> suppliers =
                    supplierRepo.findAllById(supplierIds);

            if (suppliers.size() != supplierIds.size()) {
                throw new ResourceNotFoundException(
                        SUPPLIER_NOT_FOUND,
                        "Invalid supplier IDs"
                );
            }

            entity.getSuppliers().clear();
            entity.getSuppliers().addAll(suppliers);
        }

        if (customerId != null) {

            CustomerEntity customer = customerRepo
                    .findById(customerId)
                    .orElseThrow(() ->
                            new ResourceNotFoundException(
                                    CUSTOMER_NOT_FOUND,
                                    String.valueOf(customerId)
                            )
                    );

            entity.setCustomer(customer);
        }
    }

    private void handleImages(PurchaseEntity entity, List<MultipartFile> images) {

        if (images == null || images.isEmpty()) {
            return;
        }

        List<String> imageUrls =
                fileUploadService.uploadFiles(images, MODULE);

        List<PurchaseImageEntity> imageEntities =
                imageUrls.stream()
                        .map(url -> {
                            PurchaseImageEntity image = new PurchaseImageEntity();
                            image.setImageUrl(url);
                            image.setPurchase(entity);
                            return image;
                        })
                        .collect(Collectors.toList());

        entity.setImages(imageEntities);
    }

}
