package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddCreditEntryRequestDto;
import com.code.monks.csm.dto.request.CreditUpdateRequest;
import com.code.monks.csm.dto.response.AddCreditEntryResponseDto;
import com.code.monks.csm.dto.response.GetCreditEntries;
import com.code.monks.csm.dto.response.PagedResponseDto;
import com.code.monks.csm.dto.response.SearchCreditEntryResponse;
import com.code.monks.csm.entity.CreditEntryEntity;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.enums.CreditEntryEnum;
import com.code.monks.csm.enums.DrawTypeEnum;
import com.code.monks.csm.exception.CreditException;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.repository.BillEntryRepo;
import com.code.monks.csm.repository.CreditEntryRepo;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.service.CreditService;
import com.code.monks.csm.specification.GenericSpecificationBuilder;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static com.code.monks.csm.enums.ResponseErrorCode.*;

@Service
@AllArgsConstructor
@Slf4j
public class CreditServiceImpl implements CreditService {

    private final CreditEntryRepo creditEntryRepo;

    private final CustomerRepo customerRepo;

    private final SupplierRepo supplierRepo;

    private final BillEntryRepo billEntryRepo;

    @Transactional
    public AddCreditEntryResponseDto addCreditEntry(AddCreditEntryRequestDto requestDto) {

        log.info("Attempting to add credit entry: {}", requestDto);

        try {
            if (requestDto.getPaymentType() == CreditEntryEnum.CHEQUE) {

                if (!StringUtils.hasText(requestDto.getReferenceNumber())) {
                    throw new CreditException(
                            INVALID_REQUEST,
                            "Cheque number is required for CHEQUE payment"
                    );
                }

                if (requestDto.getReferenceDate() == null) {
                    throw new CreditException(
                            INVALID_REQUEST,
                            "Cheque date is required for CHEQUE payment"
                    );
                }
            }

            List<String> errorMessages = new ArrayList<>();

            // Bill number duplicate
//            if (billEntryRepo.existsByBillNumber(requestDto.getBillNumber())) {
//                errorMessages.add("Bill number already exists");
//            }

            // Cheque number duplicate → ONLY FOR CHEQUE
            if (requestDto.getPaymentType() == CreditEntryEnum.CHEQUE &&
                    creditEntryRepo.existsByReferenceNumber(requestDto.getReferenceNumber())) {

                errorMessages.add("Cheque number already exists");
            }

            if (!errorMessages.isEmpty()) {
                throw new CreditException(
                        DUPLICATE_ENTRY,
                        String.join(", ", errorMessages)
                );
            }

            CreditEntryEntity entity = AddCreditEntryResponseDto.dtoToEntity(requestDto);
            creditEntryRepo.save(entity);

            log.info("Credit entry saved successfully with bill number: {}", entity.getBillNumber());

            return AddCreditEntryResponseDto.builder()
                    .message("Credit entry successfully added.")
                    .build();

        } catch (CreditException ce) {
            throw ce;
        } catch (Exception ex) {
            log.error("Failed to add credit entry. Request data: {}", requestDto, ex);
            throw new CreditException(UNEXPECTED_EXCEPTION, "Unable to add credit");
        }
    }

    @Override
    public List<GetCreditEntries> getCreditEntries() {
        log.info("Fetching all credit entries from the database.");

        try {
            List<CreditEntryEntity> creditEntryEntities = creditEntryRepo.findAll();
            log.info("Fetched {} credit entry records from DB.", creditEntryEntities.size());

            List<GetCreditEntries> result = creditEntryEntities.stream()
                    .map(GetCreditEntries::convertToGetCreditEntries)
                    .toList();

            log.info("Converted {} credit entry entities to DTOs.", result.size());
            return result;

        } catch (DataAccessException dae) {
            log.error("Database access error while fetching credit entries.", dae);
            throw new CreditException(DATA_ACCESS_ERROR, dae.getMessage());

        } catch (Exception ex) {
            log.error("Unexpected error while fetching credit entries.", ex);
            throw new CreditException(UNEXPECTED_EXCEPTION, " fetching credit entries.");
        }
    }

    public PagedResponseDto<SearchCreditEntryResponse> searchCreditHistory(
            LocalDate fromDate,
            LocalDate toDate,
            Integer supplierId,
            Integer customerId,
            int page,
            int size) {

        log.info("SearchCreditHistory called with fromDate={}, toDate={}, supplierId={}, customerId={}, page={}, size={}",
                fromDate, toDate, supplierId, customerId, page, size);

        int pageIndex = Math.max(page, 0);

        Pageable pageable = PageRequest.of(
                pageIndex,
                size,
                Sort.by(
                        Sort.Order.desc("date"),
                        Sort.Order.desc("id")
                )
        );

        Specification<CreditEntryEntity> spec =
                new GenericSpecificationBuilder<CreditEntryEntity>()
                        .fromDate("date", fromDate)
                        .toDate("date", toDate)
                        .equal("supplierId", supplierId)
                        .equal("customerId", customerId)
                        .build();

        Page<CreditEntryEntity> records =
                creditEntryRepo.findAll(spec, pageable);

        log.info("Fetched {} credit records", records.getTotalElements());

        List<SearchCreditEntryResponse> content = records.getContent()
                .stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());

        return new PagedResponseDto<>(
                content,
                records.getNumber(),
                records.getSize(),
                records.getTotalElements(),
                records.getTotalPages(),
                records.isLast()
        );
    }

    @Override
    public Map<String, Object> deleteCreditEntry(int id ) {

        CreditEntryEntity creditEntry = creditEntryRepo.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                CREDIT_ENTRY_NOT_FOUND,
                                " with id " + id
                        )
                );
        creditEntryRepo.delete(creditEntry);

        return Map.of(
                "message", "credit Entry deleted successfully",
                "id", id
        );
    }

    @Override
    public Map<String, Object> updateCreditEntry(
            int id,
            CreditUpdateRequest request) {

        CreditEntryEntity credit = creditEntryRepo.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                CREDIT_ENTRY_NOT_FOUND,
                                " with id " + id
                        )
                );

        // 🔹 Party updates
        if (request.getSupplierId() != null) {
            credit.setSupplierId(request.getSupplierId());
        }

        if (request.getCustomerId() != null) {
            credit.setCustomerId(request.getCustomerId());
        }

        // 🔹 Transaction details
        if (request.getPaymentType() != null) {
            credit.setPaymentType(
                    CreditEntryEnum.valueOf(request.getPaymentType())
            );
        }
        credit.setReferenceNumber(request.getReferenceNumber());
        credit.setDate(request.getDate());
        credit.setReferenceDate(request.getReferenceDate());
        credit.setSlipNumber(request.getSlipNumber());
        if (request.getDrawType() != null) {
            credit.setDrawType(
                    DrawTypeEnum.valueOf(request.getDrawType())
            );
        }
        long amount = request.getReceivedAmount() == null
                ? 0L
                : Math.round(request.getReceivedAmount() * 100);
        credit.setReceivedAmount(amount);
        credit.setRemark(request.getRemark());

        creditEntryRepo.save(credit);

        return Map.of(
                "message", "Credit updated successfully",
                "id", id
        );
    }


    private SearchCreditEntryResponse convertToResponseDto(CreditEntryEntity entity) {
        CustomerEntity customerEntity = null;
        SupplierEntity supplierEntity = null;

        // ✅ Only fetch from DB if IDs are > 0
        if (entity.getCustomerId() > 0) {
            customerEntity = customerRepo.findById(entity.getCustomerId()).orElse(null);
        }

        if (entity.getSupplierId() > 0) {
            supplierEntity = supplierRepo.findById(entity.getSupplierId()).orElse(null);
        }

        return SearchCreditEntryResponse.builder()
                .id(entity.getId())
                .supplierId(entity.getSupplierId())
                .customerId(entity.getCustomerId())
                .paymentType(entity.getPaymentType())
                .billNumber(entity.getBillNumber())
                .date(entity.getDate())
                .referenceNumber(entity.getReferenceNumber())
                .referenceDate(entity.getReferenceDate())
                .receivedAmount(entity.getReceivedAmount() / 100.0)
                .supplierName(supplierEntity != null ? supplierEntity.getSupplierName() : null)
                .customerName(customerEntity != null ? customerEntity.getCustomerName() : null)
                .slipNumber(entity.getSlipNumber())
                .drawType(entity.getDrawType())
                .remark(entity.getRemark())
                .build();
    }

}
