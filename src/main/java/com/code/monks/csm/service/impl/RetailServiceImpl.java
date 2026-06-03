package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.RetailRequestDto;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.RetailResponseDto;
import com.code.monks.csm.dto.response.RetailerListResponseDto;
import com.code.monks.csm.entity.*;
import com.code.monks.csm.enums.ResponseErrorCode;
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
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class RetailServiceImpl implements RetailService {

    private final RetailRepository retailRepository;
    private final CustomerRepo customerRepository;
    private final StaffRepo staffRepository;
    private final SupplierRepo supplierRepository;
    private final RetailMapper retailMapper;


    @Override
    @Transactional
    public void createRetail(RetailRequestDto request) {

        log.info("Creating retailer with name: {}, customerId: {}, staffId: {}",
                request.name(),
                request.customerId(),
                request.staffId());

        var retailer = new RetailerEntity();
        retailer.setName(request.name());
        retailer.setCustomer(getCustomer(request.customerId()));
        retailer.setStaff(getStaff(request.staffId()));
        retailer.setSuppliers(buildRetailSuppliers(retailer, request));
        retailRepository.save(retailer);
        log.info("Retailer created successfully with id: {}", retailer.getId());
    }

    @Override
    @Transactional
    public void updateRetail(Long retailId, RetailRequestDto request) {

        log.info("Updating retailer with id: {}", retailId);
        var retailer = getRetail(retailId);
        retailer.setName(request.name());
        retailer.setTransactionDate(request.transactionDate());
        retailer.setCustomer(getCustomer(request.customerId()));
        retailer.setStaff(getStaff(request.staffId()));
        retailer.getSuppliers().clear();
        retailer.getSuppliers().addAll(buildRetailSuppliers(retailer, request));
        log.info("Retailer updated successfully with id: {}", retailId);
    }

    @Override
    @Transactional(readOnly = true)
    public RetailResponseDto getRetailDetails(Long retailId) {

        log.info("Fetching retailer details for id: {}", retailId);
        var retailer = retailRepository.findRetailDetailsById(retailId)
                .orElseThrow(() -> {
                    log.warn("Retailer not found with id: {}", retailId);
                    return new ResourceNotFoundException(
                            ResponseErrorCode.RETAIL_NOT_FOUND,
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
                                Sort.Order.desc("transactionDate"),
                                Sort.Order.desc("id")
                        )
                );

        Specification<RetailerEntity> spec =
                new GenericSpecificationBuilder<RetailerEntity>()
                        .fromDate("transactionDate", fromDate)
                        .toDate("transactionDate", toDate)
                        .joinEqual("customer", "id", customerId)
                        .joinEqual("staff", "id", staffId)
                        .joinJoinEqual("suppliers", "supplier", "id", supplierId)
                        .build();

        Page<RetailerEntity> retailers = retailRepository.findAll(spec, pageable);
        List<RetailerListResponseDto> content =
                retailers.getContent()
                        .stream()
                        .flatMap(retail ->
                                retailMapper.toListDto(retail).stream())
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

    private List<RetailSupplierEntity> buildRetailSuppliers(RetailerEntity retailer, RetailRequestDto request) {

        return request.suppliers()
                .stream()
                .map(item -> {
                    var relation = new RetailSupplierEntity();
                    relation.setRetail(retailer);
                    relation.setSupplier(getSupplier(item.supplierId()));
                    relation.setBalanceAmount(item.balanceAmount());
                    relation.setDepositAmount(item.depositAmount());
                    relation.setTotalAmount(item.totalAmount());
                    return relation;
                })
                .toList();
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
                                ResponseErrorCode.RETAIL_NOT_FOUND,
                                " : Retail Id = " + retailId
                        ));
    }
}
