package com.code.monks.csm.service.impl;

import com.code.monks.csm.common.BillItemCommon;
import com.code.monks.csm.dto.request.BillEntryRequestDto;
import com.code.monks.csm.dto.request.BillUpdateRequest;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.BillDetailEntity;
import com.code.monks.csm.entity.BillEntryEntity;
import com.code.monks.csm.entity.BillImageEntity;
import com.code.monks.csm.entity.TransportEntity;
import com.code.monks.csm.enums.UploadModuleEnum;
import com.code.monks.csm.exception.BillException;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.mapper.BillMapper;
import com.code.monks.csm.repository.BillEntryRepo;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.service.BillService;
import com.code.monks.csm.service.TransportService;
import com.code.monks.csm.service.file.FileService;
import com.code.monks.csm.specification.GenericSpecificationBuilder;
import com.code.monks.csm.utils.MoneyUtil;
import io.micrometer.common.util.StringUtils;
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
public class BillServiceImpl implements BillService {

    private final BillEntryRepo billRepo;
    private final CustomerRepo customerRepo;
    private final SupplierRepo supplierRepo;
    private final TransportService transportService;
    private final FileService fileService;
    private final BillMapper billMapper;

    @Transactional
    public BillEntryResponseDto addBill(
            BillEntryRequestDto requestDto,
            List<MultipartFile> images) {

        log.info("AddBill request received | order={} | supplierId={} | customerId={} | taxableValue={} | billAmount={}",
                requestDto.getOrder(),
                requestDto.getSupplierId(),
                requestDto.getCustomerId(),
                requestDto.getTaxableValue(),
                requestDto.getBillAmount());

        checkLrNumberDuplicate(requestDto.getLrNumber());

        BillEntryEntity billEntry = new BillEntryEntity();

        // Header mapping
        mapHeaderFields(billEntry, requestDto);

        // Money fields
        billEntry.setTaxableValue(
                MoneyUtil.toPaisa(requestDto.getTaxableValue()));
        billEntry.setBillAmount(
                MoneyUtil.toPaisa(requestDto.getBillAmount()));

        // Detail mapping
        List<BillDetailEntity> billItems =
                mapToBillDetails(requestDto.getBillItems(), billEntry);

        billEntry.setBillDetails(billItems);

        // Images
        handleBillImages(billEntry, images);

        log.info("Saving Bill | billNumber={} | taxablePaisa={} | billAmountPaisa={}",
                billEntry.getBillNumber(),
                billEntry.getTaxableValue(),
                billEntry.getBillAmount());

        billRepo.save(billEntry);

        return BillEntryResponseDto.builder()
                .message("Bill added successfully: " + billEntry.getBillNumber())
                .build();
    }

    @Transactional
    @Override
    public EditBillEntryResponse updateBill(
            Integer id,
            BillUpdateRequest request,
            List<MultipartFile> newImages
    ) {

        log.info("UpdateBill request | id={} | taxableValue={} | billAmount={}",
                id,
                request.getTaxableValue(),
                request.getBillAmount());

        BillEntryEntity bill = billRepo.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(BILL_NOT_FOUND, "with id "+id));

        // Header mapping
        mapHeaderFieldsForUpdate(bill, request);

        // Clear old details
        bill.getBillDetails().clear();

        // Re-map details
        List<BillDetailEntity> newDetails =
                mapToBillDetails(request.getBillItems(), bill);

        bill.getBillDetails().addAll(newDetails);

        // Header totals
        bill.setTaxableValue(
                MoneyUtil.toPaisa(request.getTaxableValue()));
        bill.setBillAmount(
                MoneyUtil.toPaisa(request.getBillAmount()));

        handleBillImageUpdate(
                bill,
                request.getExistingImageKeys(),
                newImages
        );
        billRepo.save(bill);

        return EditBillEntryResponse.builder()
                .message("Bill updated successfully!")
                .build();
    }

    @Override
    public PagedResponseDto<BillListResponseDto> searchBillHistory(
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

        Pageable pageable = PageRequest.of(
                page,
                size,
                Sort.by(
                        Sort.Order.desc("date"),
                        Sort.Order.desc("id")
                )
        );

        Specification<BillEntryEntity> spec =
                new GenericSpecificationBuilder<BillEntryEntity>()
                        .fromDate("date", fromDate)
                        .toDate("date", toDate)
                        .joinEqual("supplier", "id", supplierId)
                        .joinEqual("customer", "id", customerId)
                        .build();

        Page<BillEntryEntity> billRecords =
                billRepo.findAll(spec, pageable);

        List<BillListResponseDto> content =
                billRecords.getContent()
                        .stream()
                        .map(billMapper::toListDto)
                        .toList();

        log.info("Search result fetched | totalRecords={} | page={}",
                billRecords.getTotalElements(),
                billRecords.getNumber());
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
    public BillDetailResponseDto getBillDetail(String billNumber) {

        log.info("Fetching bill detail | billNumber={}", billNumber);
        BillEntryEntity entity = billRepo.findByBillNumber(billNumber)
                .orElseThrow(() -> {
                    log.warn("Bill not found | billNumber={}", billNumber);
                    return new ResourceNotFoundException(BILL_NOT_FOUND, billNumber);
                });
        BillDetailResponseDto response = billMapper.toDetailDto(entity);
        log.info("Bill detail mapped successfully | billNumber={}", billNumber);
        return response;
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

    private List<BillDetailEntity> mapToBillDetails(
            List<? extends BillItemCommon> items,
            BillEntryEntity billEntry) {

        List<BillDetailEntity> details = new ArrayList<>();

        for (BillItemCommon dto : items) {

            log.info("Incoming Percent From DTO | discountPercent={} | gstPercent={}",
                    dto.getDiscountPercent(),
                    dto.getGstPercent());

            int discountBP = MoneyUtil.percentToBasisPoint(dto.getDiscountPercent());
            int gstBP = MoneyUtil.percentToBasisPoint(dto.getGstPercent());

            log.info("Converted Percent To BasisPoint | discountBP={} | gstBP={}",
                    discountBP, gstBP);
            BillDetailEntity detail = new BillDetailEntity();

            detail.setPieces(dto.getPieces());
            detail.setGrossAmount(MoneyUtil.toPaisa(dto.getGrossAmount()));
            detail.setDiscountAmount(MoneyUtil.toPaisa(dto.getDiscountAmount()));
            detail.setAddOnAmount(MoneyUtil.toPaisa(dto.getAddOnAmount()));
            detail.setEcrAmount(MoneyUtil.toPaisa(dto.getEcrAmount()));
            detail.setGstAmount(MoneyUtil.toPaisa(dto.getGstAmount()));

            detail.setDiscountPercent(discountBP);
            detail.setGstPercent(gstBP);

            detail.setBillEntry(billEntry);

            details.add(detail);
        }

        return details;
    }

    private void mapHeaderFields(
            BillEntryEntity bill,
            BillEntryRequestDto dto) {

        String billNumber = generateBillNumber();
        bill.setBillNumber(billNumber);
        bill.setDate(dto.getDate());
        bill.setReceivedDate(dto.getReceivedDate());
        bill.setInvoiceNo(dto.getOrder());
        bill.setSupplier(
                supplierRepo.getReferenceById(dto.getSupplierId())
        );

        bill.setCustomer(
                customerRepo.getReferenceById(dto.getCustomerId())
        );
        bill.setLrNumber(dto.getLrNumber());
        bill.setRemarks(dto.getRemarks());

        if (dto.getTransportName() != null &&
                !dto.getTransportName().trim().isEmpty()) {

            TransportEntity transport =
                    transportService.getOrCreateTransport(
                            dto.getTransportName().trim());

            bill.setTransportEntity(transport);
        }
    }

    private void mapHeaderFieldsForUpdate(
            BillEntryEntity bill,
            BillUpdateRequest dto) {

        bill.setDate(LocalDate.parse(dto.getDate()));

        Optional.ofNullable(dto.getReceivedDate())
                .filter(d -> !d.trim().isEmpty())
                .map(LocalDate::parse)
                .ifPresent(bill::setReceivedDate);

        bill.setInvoiceNo(dto.getOrder());
        if (dto.getSupplierId() != null) {
            bill.setSupplier(
                    supplierRepo.getReferenceById(dto.getSupplierId())
            );
        }
        if (dto.getCustomerId() != null) {
            bill.setCustomer(
                    customerRepo.getReferenceById(dto.getCustomerId())
            );
        }
        bill.setLrNumber(dto.getLrNumber());
        bill.setRemarks(dto.getRemarks());

        if (dto.getTransport() == null ||
                dto.getTransport().trim().isEmpty()) {

            bill.setTransportEntity(null);

        } else {

            TransportEntity transport =
                    transportService.findByNameIgnoreCase(
                                    dto.getTransport().trim())
                            .orElseThrow(() ->
                                    new BillException(
                                            TRANSPORT_NOT_FOUND,
                                            "Transport not found"));

            bill.setTransportEntity(transport);
        }
    }

    /**
     * Handle images upload for ADD bill case
     */
    private void handleBillImages(
            BillEntryEntity entity,
            List<MultipartFile> images
    ) {

        if (images == null || images.isEmpty()) {
            log.info("No images provided for bill {}", entity.getBillNumber());
            return;
        }

        log.info("Uploading {} bill image(s) for bill {}",
                images.size(),
                entity.getBillNumber());

        List<FileUploadResponse> uploadedFiles =
                fileService.uploadFiles(
                        images,
                        UploadModuleEnum.BILTY
                );
        List<BillImageEntity> imageEntities =
                mapToBillImages(entity, images, uploadedFiles);
        entity.setImages(imageEntities);

        log.info("Successfully uploaded {} image(s) for bill {}",
                imageEntities.size(),
                entity.getBillNumber());
    }

    /**
     * Handle image update for UPDATE bill case
     */
    private void handleBillImageUpdate(
            BillEntryEntity entity,
            List<String> existingKeys,
            List<MultipartFile> newImages
    ) {

        List<BillImageEntity> currentImages = entity.getImages();

        if (currentImages == null) {
            currentImages = new ArrayList<>();
            entity.setImages(currentImages);
        }

        log.info("Starting image update for bill {} | existingImages={}",
                entity.getBillNumber(),
                currentImages.size());


        // Remove
        Iterator<BillImageEntity> iterator = currentImages.iterator();
        int removeCount = 0;
        while (iterator.hasNext()) {
            BillImageEntity img = iterator.next();

            if (existingKeys != null &&
                    !existingKeys.contains(img.getObjectKey())) {

                String key = img.getObjectKey();
                iterator.remove();
                removeCount++;
                log.info("Removed image reference from DB | bill={} | key={}",
                        entity.getBillNumber(),
                        key);
                fileService.deleteFile(img.getObjectKey());

                log.info("Deleted image from cloud storage | bill={} | key={}",
                        entity.getBillNumber(),
                        key);
            }
        }
        log.info("Images removed count={} for bill {}",
                removeCount,
                entity.getBillNumber());

        // Upload new images
        if (newImages != null && !newImages.isEmpty()) {

            log.info("Uploading {} new image(s) for bill {}",
                    newImages.size(),
                    entity.getBillNumber());

            List<FileUploadResponse> uploadedFiles =
                    fileService.uploadFiles(
                            newImages,
                            UploadModuleEnum.BILTY
                    );
            List<BillImageEntity> newImageEntities =
                    mapToBillImages(entity, newImages, uploadedFiles);

            currentImages.addAll(newImageEntities);
        }

        log.info("Image update completed for bill {} | finalImageCount={}",
                entity.getBillNumber(),
                currentImages.size());
    }

    private List<BillImageEntity> mapToBillImages(
            BillEntryEntity entity,
            List<MultipartFile> files,
            List<FileUploadResponse> responses
    ) {
        List<BillImageEntity> images = new ArrayList<>();

        for (int i = 0; i < responses.size(); i++) {

            MultipartFile file = files.get(i);
            FileUploadResponse response = responses.get(i);

            BillImageEntity image = new BillImageEntity();
            image.setObjectKey(response.getKey());
            image.setPublicUrl(response.getPublicUrl());
            image.setOriginalFileName(file.getOriginalFilename());
            image.setBillEntry(entity);

            images.add(image);
        }

        return images;
    }
}
