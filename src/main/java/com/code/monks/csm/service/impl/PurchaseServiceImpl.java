package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.dto.request.UpdatePurchaseEntryReq;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.*;
import com.code.monks.csm.enums.UploadModuleEnum;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.mapper.PurchaseMapper;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.PurchaseEntryRepo;
import com.code.monks.csm.repository.StaffRepo;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.service.PurchaseService;
import com.code.monks.csm.service.file.FileUploadService;
import com.code.monks.csm.specification.GenericSpecificationBuilder;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.*;

import static com.code.monks.csm.enums.ResponseErrorCode.*;

@Service
@AllArgsConstructor
@Slf4j
public class PurchaseServiceImpl implements PurchaseService {

    private final PurchaseEntryRepo purchaseEntryRepo;
    private final CustomerRepo customerRepo;
    private final SupplierRepo supplierRepo;
    private final StaffRepo staffRepo;
    private final FileService fileUploadService;
    private final PurchaseMapper purchaseMapper;

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
            int size)
    {

        int pageIndex = Math.max(page, 0);
        Pageable pageable = PageRequest.of(
                pageIndex,
                size,
                Sort.by(
                        Sort.Order.desc("date"),
                        Sort.Order.desc("id")
                )
        );

        log.info("Purchase search called: fromDate={}, toDate={}, supplierId={}, customerId={}",
                fromDate, toDate, supplierId, customerId);

        GenericSpecificationBuilder<PurchaseEntity> builder =
                new GenericSpecificationBuilder<>();

        Specification<PurchaseEntity> spec = builder
                .fromDate("date", fromDate)
                .toDate("date", toDate)
                .joinEqual("suppliers", "id", supplierId)
                .joinEqual("customer", "id", customerId)
                .build();

        Page<PurchaseEntity> purchaseRecords =
                purchaseEntryRepo.findAll(spec, pageable);

        List<SearchPurchaseEntryResponse> content =
                purchaseRecords.getContent()
                        .stream()
                        .map(purchaseMapper::toSearch)
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
    public Map<String, Object> updatePurchaseEntry(
            int id,
            UpdatePurchaseEntryReq req,
            List<MultipartFile> newImages
    ) {

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
        handleImageUpdate(entity, req.getExistingImageKeys(), newImages);
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

    @Override
    @Transactional(readOnly = true)
    public PurchaseDetailResponse getPurchaseById(int id) {

        PurchaseEntity entity = purchaseEntryRepo.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                PURCHASE_ENTRY_NOT_FOUND,
                                String.valueOf(id)
                        )
                );

        return purchaseMapper.toDetail(entity);
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

        List<FileUploadResponse> uploadedFiles =
                fileUploadService.uploadFiles(
                        images,
                        UploadModuleEnum.PURCHASE
                );

        List<PurchaseImageEntity> imageEntities =
                uploadedFiles.stream()
                        .map(response -> {
                            PurchaseImageEntity image =
                                    new PurchaseImageEntity();

                            image.setObjectKey(response.getKey());
                            image.setPublicUrl(response.getPublicUrl());
                            image.setPurchase(entity);

                            return image;
                        })
                        .toList();

        entity.setImages(imageEntities);
    }

    private void handleImageUpdate(
            PurchaseEntity entity,
            List<String> existingKeys,
            List<MultipartFile> newImages
    ) {

        List<PurchaseImageEntity> currentImages = entity.getImages();

        if (currentImages == null) {
            currentImages = new ArrayList<>();
            entity.setImages(currentImages);
        }

        // Identify removed images
        List<PurchaseImageEntity> toRemove =
                currentImages.stream()
                        .filter(img -> existingKeys == null ||
                                !existingKeys.contains(img.getObjectKey()))
                        .toList();

        // Remove from entity
        currentImages.removeAll(toRemove);

        // Delete from storage
        for (PurchaseImageEntity img : toRemove) {
            fileUploadService.deleteFile(img.getObjectKey());
        }

        //Upload new images
        if (newImages != null && !newImages.isEmpty()) {

            List<FileUploadResponse> uploadedFiles =
                    fileUploadService.uploadFiles(
                            newImages,
                            UploadModuleEnum.PURCHASE
                    );

            for (FileUploadResponse response : uploadedFiles) {

                PurchaseImageEntity image = new PurchaseImageEntity();
                image.setObjectKey(response.getKey());
                image.setPublicUrl(response.getPublicUrl());
                image.setPurchase(entity);

                currentImages.add(image);
            }
        }
    }
}
