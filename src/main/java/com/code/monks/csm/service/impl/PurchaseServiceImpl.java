package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.purchase.PurchaseDetailResponse;
import com.code.monks.csm.dto.request.AddPurchaseEntryRequestDto;
import com.code.monks.csm.dto.request.CopySupplierDetailsRequest;
import com.code.monks.csm.dto.request.SupplierPurchaseDto;
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
import com.code.monks.csm.service.file.FileService;
import com.code.monks.csm.service.file.validator.FileValidator;
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
import org.springframework.util.MultiValueMap;
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
    private final FileService fileService;
    private final PurchaseMapper purchaseMapper;
    private final FileValidator fileValidator;
    private final StaffRepo staffRepo;

    @Override
    @Transactional
    public AddPurchaseEntryResponseDto addPurchaseEntry(
            AddPurchaseEntryRequestDto requestDto,
            MultiValueMap<String, MultipartFile> supplierImages
    ) {

        log.info("Add Purchase Entry API called | suppliersCount={}",
                requestDto.getSuppliers() != null ? requestDto.getSuppliers().size() : 0);

        List<SupplierPurchaseDto> suppliers = requestDto.getSuppliers();

        List<PurchaseEntity> entities = new ArrayList<>();

        for (SupplierPurchaseDto supplierDto : suppliers) {

            Integer supplierId = supplierDto.getSupplierId();

            log.info("Processing purchase entry | supplierId={}", supplierId);

            PurchaseEntity entity = new PurchaseEntity();
            applyRequestToEntity(
                    entity,
                    requestDto.getDate(),
                    requestDto.getStaffId(),
                    supplierId,
                    requestDto.getCustomerId(),
                    supplierDto.getRemarks()
            );

            List<MultipartFile> images = Collections.emptyList();

            if (supplierImages != null) {
                images = supplierImages.getOrDefault(
                        "supplier_" + supplierId + "_images",
                        Collections.emptyList()
                );
            }

            // validation (max images)
            fileValidator.validate(images);

            if (!images.isEmpty()) {

                log.info("Uploading {} image(s) for supplierId={}",
                        images.size(),
                        supplierId);

                handleImages(entity, images);

            } else {

                log.info("Saving purchase entry without images | supplierId={}", supplierId);
            }

            entities.add(entity);
        }

        purchaseEntryRepo.saveAll(entities);

        log.info("All purchase entries saved successfully | totalSuppliers={}",
                entities.size());

        return AddPurchaseEntryResponseDto.builder()
                .message("Purchase entries saved successfully")
                .build();
    }

    public PagedResponseDto<PurchaseHistoryResponseDto> searchPurchaseHistory(
            LocalDate fromDate,
            LocalDate toDate,
            Integer supplierId,
            Integer customerId,
            Integer staffId,
            int page,
            int size)
    {

        int pageIndex = Math.max(page, 0);
        Pageable pageable = PageRequest.of(
                pageIndex,
                size,
                Sort.by(
                        Sort.Order.desc("date"),
                        Sort.Order.desc("createdAt"),
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
                .joinEqual("supplier", "id", supplierId)
                .joinEqual("customer", "id", customerId)
                .equal("staffId", staffId)
                .build();

        Page<PurchaseEntity> purchaseRecords =
                purchaseEntryRepo.findAll(spec, pageable);

        List<PurchaseHistoryResponseDto> content =
                purchaseRecords.getContent()
                        .stream()
                        .map(entity -> {

                            String staffName = null;

                            if (entity.getStaffId() != null) {
                                staffName = staffRepo.findById(entity.getStaffId())
                                        .map(StaffEntity::getStaffName)
                                        .orElse(null);
                            }

                            return purchaseMapper.toSearch(entity, staffName);
                        })
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
            MultiValueMap<String, MultipartFile> supplierImages
    ) {

        log.info("Update Purchase Entry called | purchaseId={}", id);

        PurchaseEntity entity = purchaseEntryRepo.findById(id)
                .orElseThrow(() -> {
                    log.error("Purchase entry not found | purchaseId={}", id);
                    return new ResourceNotFoundException(
                            PURCHASE_ENTRY_NOT_FOUND,
                            String.valueOf(id)
                    );
                });

        log.info("Updating purchase entry | purchaseId={} | supplierId={}",
                id,
                req.getSupplierId());

        applyRequestToEntity(
                entity,
                req.getDate(),
                req.getStaffId(),
                req.getSupplierId(),
                req.getCustomerId(),
                req.getRemarks()
        );

        List<MultipartFile> newImages = Collections.emptyList();

        if (supplierImages != null) {
            newImages = supplierImages.getOrDefault(
                    "supplier_" + req.getSupplierId() + "_images",
                    Collections.emptyList()
            );
        }

        fileValidator.validate(newImages);

        log.info("Updating images | purchaseId={} | existingKeysCount={} | newImagesCount={}",
                id,
                req.getExistingImageKeys() != null ? req.getExistingImageKeys().size() : 0,
                newImages.size());

        handleImageUpdate(
                entity,
                req.getExistingImageKeys(),
                newImages
        );

        purchaseEntryRepo.save(entity);

        log.info("Purchase entry updated successfully | purchaseId={}", id);

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Purchase entry updated successfully");

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

        log.info("Get Purchase Detail API called | purchaseId={}", id);

        PurchaseEntity purchase = purchaseEntryRepo.findById(id)
                .orElseThrow(() -> {
                    log.error("Purchase entry not found | purchaseId={}", id);
                    return new ResourceNotFoundException(
                            PURCHASE_ENTRY_NOT_FOUND,
                            String.valueOf(id)
                    );
                });

        StaffEntity staff = null;

        if (purchase.getStaffId() != null) {

            staff = staffRepo.findById(purchase.getStaffId()).orElse(null);

        }

        PurchaseDetailResponse response =
                purchaseMapper.toDetail(purchase,
                        staff != null ? staff.getStaffName() : null);

        log.info("Purchase detail response prepared successfully | purchaseId={}", id);

        return response;
    }

    private void applyRequestToEntity(
            PurchaseEntity entity,
            LocalDate date,
            Integer staffId,
            Integer supplierId,
            Integer customerId,
            String remarks
    ) {

        if (date != null) {
            entity.setDate(date);
        }

        if (staffId != null) {
            entity.setStaffId(staffId);
        }

        if (remarks != null) {
            entity.setRemarks(remarks);
        }

        if (supplierId != null) {

            SupplierEntity supplier = supplierRepo
                    .findById(supplierId)
                    .orElseThrow(() ->
                            new ResourceNotFoundException(
                                    SUPPLIER_NOT_FOUND,
                                    String.valueOf(supplierId)
                            )
                    );

            entity.setSupplier(supplier);
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
            log.info("No images provided for Purchase entry");
            return;
        }

        log.info("Uploading {} image(s) for Purchase entry",
                images.size());

        List<FileUploadResponse> uploadedFiles =
                fileService.uploadFiles(
                        images,
                        UploadModuleEnum.PURCHASE
                );

        List<PurchaseImageEntity> imageEntities =
                mapToPurchaseImages(entity, images, uploadedFiles);

        entity.setImages(imageEntities);
        log.info("Successfully uploaded {} image(s) for Purchase entry",
                imageEntities.size());
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

        log.info("Starting image update | existingImages={}",
                currentImages.size());

        // Identify removed images
        List<PurchaseImageEntity> toRemove =
                currentImages.stream()
                        .filter(img -> existingKeys == null ||
                                !existingKeys.contains(img.getObjectKey()))
                        .toList();
        log.info("Images to remove count={}", toRemove.size());
        // Remove from entity
        currentImages.removeAll(toRemove);

        // Delete from storage
        for (PurchaseImageEntity img : toRemove) {
            fileService.deleteFile(img.getObjectKey());
            log.info("Deleted image from storage | key={}", img.getObjectKey());
        }

        //Upload new images
        if (newImages != null && !newImages.isEmpty()) {
            log.info("Uploading {} new image(s)", newImages.size());
            List<FileUploadResponse> uploadedFiles =
                    fileService.uploadFiles(
                            newImages,
                            UploadModuleEnum.PURCHASE
                    );

            List<PurchaseImageEntity> newImageEntities =
                    mapToPurchaseImages(entity, newImages, uploadedFiles);

            currentImages.addAll(newImageEntities);
        }

        log.info("Image update completed | finalImageCount={}",
                currentImages.size());
    }

    private List<PurchaseImageEntity> mapToPurchaseImages(
            PurchaseEntity entity,
            List<MultipartFile> files,
            List<FileUploadResponse> responses
    ) {

        List<PurchaseImageEntity> images = new ArrayList<>();
        for (int i = 0; i < responses.size(); i++) {
            MultipartFile file = files.get(i);
            FileUploadResponse response = responses.get(i);

            PurchaseImageEntity image = new PurchaseImageEntity();
            image.setObjectKey(response.getKey());
            image.setPublicUrl(response.getPublicUrl());
            image.setOriginalFileName(file.getOriginalFilename());
            image.setPurchase(entity);

            images.add(image);
        }
        return images;
    }


    @Override
    public CopySupplierDetailsResponseDTO copySupplierDetailsPerCustomer(CopySupplierDetailsRequest request) {

        log.info(
                "Copy supplier details requested. customerId={}, supplierId={}, staffId={}",
                request.customerId(),
                request.supplierId(),
                request.staffId()
        );

        GenericSpecificationBuilder<PurchaseEntity> builder = new GenericSpecificationBuilder<>();
        Specification<PurchaseEntity> specification = builder
                .fromDate("date", request.fromDate())
                .toDate("date", request.toDate())
                .joinEqual("supplier", "id", request.supplierId())
                .joinEqual("customer", "id", request.customerId())
                .equal("staffId", request.staffId())
                .build();

        List<PurchaseEntity> purchases = purchaseEntryRepo.findAll(specification);
        log.info("Found {} purchase records", purchases.size());

        Map<Integer, SupplierEntity> supplierMap = new LinkedHashMap<>();
        for (PurchaseEntity purchase : purchases) {
            SupplierEntity supplier = purchase.getSupplier();
            if (supplier != null) {
                supplierMap.putIfAbsent(
                        supplier.getId(),
                        supplier
                );
            }
        }
        List<CopySupplierDTO> suppliers =
                supplierMap.values()
                        .stream()
                        .map(purchaseMapper::toSupplierCopyDto)
                        .toList();

        log.info("Returning {} unique suppliers", suppliers.size());
        return new CopySupplierDetailsResponseDTO(suppliers);
    }

    @Override
    public List<PurchaseHistoryResponseDto> downloadPurchaseHistory(LocalDate fromDate, LocalDate toDate, Integer supplierId, Integer customerId, Integer staffId)
    {

        log.info("download Purchase called: fromDate={}, toDate={}, supplierId={}, customerId={}", fromDate, toDate, supplierId, customerId);

        GenericSpecificationBuilder<PurchaseEntity> builder = new GenericSpecificationBuilder<>();

        Specification<PurchaseEntity> spec = builder
                .fromDate("date", fromDate)
                .toDate("date", toDate)
                .joinEqual("supplier", "id", supplierId)
                .joinEqual("customer", "id", customerId)
                .equal("staffId", staffId)
                .build();

        Sort sort = Sort.by(
                Sort.Order.desc("date"),
                Sort.Order.desc("createdAt"),
                Sort.Order.desc("id")
        );
        List<PurchaseEntity> purchaseRecords = purchaseEntryRepo.findAll(spec, sort);

        Set<Integer> staffIds = purchaseRecords.stream()
                .map(PurchaseEntity::getStaffId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        Map<Integer, String> staffNames = staffRepo.findAllById(staffIds).stream()
                .collect(Collectors.toMap(StaffEntity::getId, StaffEntity::getStaffName));

        return purchaseRecords.stream()
                .map(entity -> purchaseMapper.toSearch(
                        entity,
                        entity.getStaffId() != null ? staffNames.get(entity.getStaffId()) : null
                ))
                .toList();
    }
}
