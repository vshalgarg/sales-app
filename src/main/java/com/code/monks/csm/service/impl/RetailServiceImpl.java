package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.*;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.RetailResponseDto;
import com.code.monks.csm.dto.response.RetailerListResponseDto;
import com.code.monks.csm.dto.response.SupplierDepositHistoryResponseDto;
import com.code.monks.csm.entity.*;
import com.code.monks.csm.enums.ResponseErrorCode;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.exception.BusinessException;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.mapper.RetailMapper;
import com.code.monks.csm.repository.*;
import com.code.monks.csm.service.RetailService;
import com.code.monks.csm.specification.GenericSpecificationBuilder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

import static com.code.monks.csm.enums.ResponseErrorCode.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class RetailServiceImpl implements RetailService {

    private final RetailRepository retailRepository;
    private final CustomerRepo customerRepository;
    private final StaffRepo staffRepository;
    private final SupplierRepo supplierRepository;
    private final RetailMapper retailMapper;
    private final RetailSupplierRepository retailSupplierRepository;
    private final RetailSupplierDepositRepository retailSupplierDepositRepository;


    @Override
    @Transactional
    public void createRetail(CreateRetailerRequestDto request) {

        log.info("Creating retailer with name: {}, customerId: {}, staffId: {}",
                request.name(),
                request.referredByCustomerId(),
                request.staffId());

        var retailer = new RetailerEntity();
        retailer.setName(request.name());
        retailer.setDate(request.date());
        retailer.setCustomer(getCustomer(request.referredByCustomerId()));
        retailer.setStaff(getStaff(request.staffId()));
        retailer.setStatus(StatusEnum.ACTIVE);
        retailer.setSuppliers(new ArrayList<>(
                        request.suppliers()
                                .stream()
                                .map(s -> buildRetailSupplier(
                                        retailer,
                                        getSupplier(s.supplierId()),
                                        s.totalAmount(),
                                        s.depositAmount(),
                                        request.date()
                                ))
                                .toList()
                )
        );
        retailRepository.save(retailer);
        log.info("Retailer created successfully with id: {}", retailer.getId());
    }

    @Override
    @Transactional
    public void updateRetail(Long retailId, UpdateRetailerRequestDto request) {

        log.info("Updating retailer with id: {}", retailId);
        var retailer = getRetail(retailId);
        retailer.setName(request.name());
        retailer.setDate(request.date());
        retailer.setCustomer(getCustomer(request.referredByCustomerId()));
        retailer.setStaff(getStaff(request.staffId()));
        log.info("Retailer updated successfully with id: {}", retailId);
    }

    @Override
    @Transactional
    public void updateRetailSupplier(Integer retailSupplierId, UpdateRetailSupplierRequestDto request) {

        log.info("Updating retail supplier. Retail Supplier Id: {}", retailSupplierId);
        var retailSupplier = retailSupplierRepository
                .findById(retailSupplierId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                RETAILER_SUPPLIER_NOT_FOUND,
                                " : Retail Supplier Id = " + retailSupplierId
                        ));
        retailSupplier.setTotalAmount(request.totalAmount());
        retailSupplier.setBalanceAmount(
                request.totalAmount() - retailSupplier.getDepositAmount()
        );

        log.info(
                "Retail supplier updated successfully. Retail Supplier Id: {}, Total Amount: {}, Deposit Amount: {}, Balance Amount: {}",
                retailSupplierId,
                retailSupplier.getTotalAmount(),
                retailSupplier.getDepositAmount(),
                retailSupplier.getBalanceAmount()
        );
    }

    @Override
    @Transactional(readOnly = true)
    public RetailResponseDto getRetailDetails(Long retailId) {

        log.info("Fetching retailer details for id: {}", retailId);
        var retailer = retailRepository.findByIdAndStatusWithActiveSuppliers(retailId, StatusEnum.ACTIVE)
                .orElseThrow(() -> {
                    log.warn("Retailer not found with id: {}", retailId);
                    return new ResourceNotFoundException(
                            RETAILER_NOT_FOUND,
                            " : Retail Id = " + retailId
                    );
                });

        log.info("Retailer details fetched successfully for id: {}", retailId);
        return retailMapper.toResponse(retailer);
    }

    @Override
    public PagedResponseDto<RetailerListResponseDto> searchRetailers(
            LocalDate fromDate,
            LocalDate toDate,
            Integer customerId,
            Integer staffId,
            Integer supplierId,
            int page,
            int size
    ) {

        Pageable pageable =
                PageRequest.of(
                        page,
                        size,
                        Sort.by(
                                Sort.Order.desc("date"),
                                Sort.Order.desc("id")
                        )
                );

        Specification<RetailerEntity> spec =
                new GenericSpecificationBuilder<RetailerEntity>()
                        .fromDate("date", fromDate)
                        .toDate("date", toDate)
                        .joinEqual("customer", "id", customerId)
                        .joinEqual("staff", "id", staffId)
                        .joinJoinEqual("suppliers", "supplier", "id", supplierId)
                        .equal("status", StatusEnum.ACTIVE)
                        .build();

        Page<RetailerEntity> retailers = retailRepository.findAll(spec, pageable);
        List<RetailerListResponseDto> content =
                retailers.getContent()
                        .stream()
                        .map(retailMapper::toListDto)
                        .toList();

        log.info(
                "Retailers fetched totalRecords={}, totalPages={}",
                retailers.getTotalElements(),
                retailers.getTotalPages()
        );

        return new PagedResponseDto<>(
                content,
                retailers.getNumber(),
                retailers.getSize(),
                retailers.getTotalElements(),
                retailers.getTotalPages(),
                retailers.isLast()
        );
    }

    @Transactional
    public void addDeposit(RetailSupplierDepositRequestDto request) {

        for (RetailSupplierDepositRequestDto.DepositDto depositRequest : request.deposits()) {
            log.info("Adding deposit for retail supplier id : {}", depositRequest.retailSupplierId());
            RetailSupplierEntity retailSupplier =
                    retailSupplierRepository.findById(depositRequest.retailSupplierId())
                            .orElseThrow(() ->
                                    new ResourceNotFoundException(
                                            RETAILER_SUPPLIER_NOT_FOUND,
                                            " : Retail Supplier Id = " + depositRequest.retailSupplierId()));

            RetailSupplierDepositEntity deposit = RetailSupplierDepositEntity.builder()
                            .retailSupplier(retailSupplier)
                            .depositDate(depositRequest.depositDate())
                            .amount(depositRequest.amount())
                            .status(StatusEnum.ACTIVE)
                            .build();

            retailSupplierDepositRepository.save(deposit);

            Long totalAmount = Optional.ofNullable(retailSupplier.getTotalAmount()).orElse(0L);
            Long currentDeposit = Optional.ofNullable(retailSupplier.getDepositAmount()).orElse(0L);
            Long updatedDepositAmount = currentDeposit + depositRequest.amount();
            Long updatedBalanceAmount = totalAmount - updatedDepositAmount;
            retailSupplier.setBalanceAmount(updatedBalanceAmount);
            retailSupplier.setBalanceAmount(updatedDepositAmount);
            retailSupplierRepository.save(retailSupplier);
            log.info("Deposits added successfully. Total Deposits Processed: {}", request.deposits().size());
        }
    }

    @Override
    @Transactional(readOnly = true)
    public List<SupplierDepositHistoryResponseDto> getDepositHistory(Long retailId) {

        log.info(
                "Fetching deposit history for retail id : {}",
                retailId
        );

        RetailerEntity retailer =
                retailRepository.findByIdAndStatus(retailId, StatusEnum.ACTIVE)
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        RETAILER_NOT_FOUND,
                                        " : Retail Id = " + retailId
                                ));

        List<Integer> retailSupplierIds =
                retailer.getSuppliers()
                        .stream()
                        .map(RetailSupplierEntity::getId)
                        .toList();
        Map<Integer, List<RetailSupplierDepositEntity>> depositsMap =
                retailSupplierDepositRepository
                        .findByRetailSupplierIdsAndStatus(retailSupplierIds, StatusEnum.ACTIVE)
                        .stream()
                        .collect(Collectors.groupingBy(
                                d -> d.getRetailSupplier().getId()
                        ));

        List<SupplierDepositHistoryResponseDto> response =
                retailer.getSuppliers()
                        .stream()
                        .map(s -> retailMapper.mapSupplierDepositHistory(
                                s,
                                depositsMap.getOrDefault(
                                        s.getId(),
                                        Collections.emptyList()
                                )
                        ))
                        .toList();

        log.info(
                "Deposit history fetched successfully for retail id : {}. Supplier count : {}",
                retailId,
                response.size()
        );

        return response;
    }

    @Transactional
    public void deleteRetailer(Long retailId) {

        RetailerEntity retailer = retailRepository.findById(retailId)
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        RETAILER_NOT_FOUND,
                                        " : Retail Id = " + retailId
                                ));

        retailSupplierDepositRepository.updateDepositStatus(
                retailId,
                StatusEnum.INACTIVE
        );

        retailSupplierRepository.updateRetailSupplierStatus(
                retailId,
                StatusEnum.INACTIVE
        );

        retailRepository.updateRetailStatus(
                retailId,
                StatusEnum.INACTIVE
        );

        log.info(
                "Retail soft deleted successfully. Retail Id : {}",
                retailId
        );
    }

    @Override
    @Transactional
    public void deleteRetailSupplier(Integer retailSupplierId) {

        log.info(
                "Deleting retail supplier. Retail Supplier Id: {}",
                retailSupplierId
        );

        var retailSupplier = retailSupplierRepository
                .findById(retailSupplierId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                RETAILER_SUPPLIER_NOT_FOUND,
                                " : Retail Supplier Id = " + retailSupplierId
                        ));

        retailSupplier.setStatus(StatusEnum.INACTIVE);

        log.info(
                "Retail supplier deleted successfully. Retail Supplier Id: {}",
                retailSupplierId
        );
    }

    @Override
    @Transactional
    public void addRetailSupplier(AddRetailSupplierRequestDto request) {

        log.info(
                "Adding supplier {} to retail {}",
                request.supplierId(),
                request.retailId()
        );

        RetailerEntity retail = retailRepository.findByIdAndStatus(
                                request.retailId(),
                                StatusEnum.ACTIVE
                        )
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        RETAILER_NOT_FOUND,
                                        " : Retail Id = " + request.retailId()
                                ));

        SupplierEntity supplier = supplierRepository.findByIdAndStatus(
                                request.supplierId(),
                                StatusEnum.ACTIVE
                        )
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        SUPPLIER_NOT_FOUND,
                                        " : Supplier Id = " + request.supplierId()
                                ));

        boolean exists = retailSupplierRepository.existsByRetailIdAndSupplierIdAndStatus(
                        request.retailId().intValue(),
                        request.supplierId(),
                        StatusEnum.ACTIVE
                );

        if (exists) {
            throw new BusinessException(RETAIL_SUPPLIER_ALREADY_ADDED);
        }

        RetailSupplierEntity retailSupplier = buildRetailSupplier(
                        retail,
                        supplier,
                        request.totalAmount(),
                        request.depositAmount(),
                        request.depositDate()
                );
        retailSupplierRepository.save(retailSupplier);
        log.info(
                "Retail supplier added successfully. Retail Id: {}, Supplier Id: {}",
                request.retailId(),
                request.supplierId()
        );
    }

    private RetailSupplierEntity buildRetailSupplier(
            RetailerEntity retailer,
            SupplierEntity supplier,
            Long totalAmount,
            Long depositAmount,
            LocalDate depositDate) {

        depositAmount = depositAmount == null ? 0L : depositAmount;
        Long balanceAmount = totalAmount != null ? totalAmount - depositAmount : null;

        RetailSupplierEntity retailSupplier = new RetailSupplierEntity();
        retailSupplier.setRetail(retailer);
        retailSupplier.setSupplier(supplier);
        retailSupplier.setTotalAmount(totalAmount);
        retailSupplier.setDepositAmount(depositAmount);
        retailSupplier.setBalanceAmount(balanceAmount);
        retailSupplier.setStatus(StatusEnum.ACTIVE);

        List<RetailSupplierDepositEntity> deposits = new ArrayList<>();

        if (depositAmount > 0) {

            RetailSupplierDepositEntity deposit = new RetailSupplierDepositEntity();
            deposit.setRetailSupplier(retailSupplier);
            deposit.setAmount(depositAmount);
            deposit.setDepositDate(
                    depositDate != null
                            ? depositDate
                            : LocalDate.now()
            );
            deposit.setStatus(StatusEnum.ACTIVE);
            deposits.add(deposit);

            log.info(
                    "Initial deposit payment created. supplierId={}, amount={}",
                    supplier.getId(),
                    depositAmount
            );
        }

        retailSupplier.setDeposits(deposits);
        return retailSupplier;
    }

    private CustomerEntity getCustomer(Integer customerId) {
        return customerRepository.findById(customerId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                ResponseErrorCode.CUSTOMER_NOT_FOUND,
                                " : Customer Id = " + customerId
                        ));
    }

    private StaffEntity getStaff(Integer staffId) {
        if (staffId == null) {
            return null;
        }
        return staffRepository.findById(staffId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                ResponseErrorCode.STAFF_NOT_FOUND,
                                " : Staff Id = " + staffId
                        ));
    }

    private SupplierEntity getSupplier(Integer supplierId) {
        return supplierRepository.findById(supplierId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                ResponseErrorCode.SUPPLIER_NOT_FOUND,
                                " : Supplier Id = " + supplierId
                        ));
    }

    private RetailerEntity getRetail(Long retailId) {
        return retailRepository.findById(retailId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                ResponseErrorCode.RETAILER_NOT_FOUND,
                                " : Retail Id = " + retailId
                        ));
    }
}
