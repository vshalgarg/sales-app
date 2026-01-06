package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.request.AddCreditEntryRequestDto;
import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.BillEntryEntity;
import com.code.monks.csm.entity.CreditEntryEntity;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.enums.CreditEntryEnum;
import com.code.monks.csm.exception.CreditException;
import com.code.monks.csm.repository.BillEntryRepo;
import com.code.monks.csm.repository.CreditEntryRepo;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.service.CreditService;
import jakarta.transaction.Transactional;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataAccessException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
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

                if (requestDto.getReferenceNumber() == null || requestDto.getReferenceNumber().isBlank()) {
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
            if (billEntryRepo.existsByBillNumber(requestDto.getBillNumber())) {
                errorMessages.add("Bill number already exists");
            }

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
            throw new CreditException(UNEXPECTED_EXCEPTION, ex.getMessage());
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
            throw new CreditException(UNEXPECTED_EXCEPTION, ex.getMessage());
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

        Pageable pageable = PageRequest.of(page - 1, size, Sort.by("date").descending());
        Page<CreditEntryEntity> creditRecords;

        // ✅ Use 0 as "no filter"
        if (supplierId !=null  && customerId != null) {
            log.info("Fetching credit entries for Supplier ID={} and Customer ID={}", supplierId, customerId);
            creditRecords = creditEntryRepo.findByDateBetweenAndSupplierIdEqualsAndCustomerIdEquals(
                    fromDate, toDate, supplierId, customerId, pageable
            );
        } else if (supplierId != null) {
            log.info("Fetching credit entries for Supplier ID={}", supplierId);
            creditRecords = creditEntryRepo.findByDateBetweenAndSupplierIdEquals(
                    fromDate, toDate, supplierId, pageable
            );
        } else if (customerId != null) {
            log.info("Fetching credit entries for Customer ID={}", customerId);
            creditRecords = creditEntryRepo.findByDateBetweenAndCustomerIdEquals(
                    fromDate, toDate, customerId, pageable
            );
        } else {
            log.info("Fetching credit entries for all suppliers and customers");
            creditRecords = creditEntryRepo.findByDateBetween(
                    fromDate, toDate, pageable
            );
        }

        log.info("Fetched {} credit records", creditRecords.getTotalElements());

        List<SearchCreditEntryResponse> content = creditRecords.getContent()
                .stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());

        return new PagedResponseDto<>(
                content,
                creditRecords.getNumber() + 1,        // current page (1-based)
                creditRecords.getSize(),              // page size
                creditRecords.getTotalElements(),     // total records
                creditRecords.getTotalPages(),        // total pages
                creditRecords.isLast()                // last page?
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
                .paymentType(entity.getPaymentType())
                .billNumber(entity.getBillNumber())
                .date(entity.getDate())
                .referenceNumber(entity.getReferenceNumber())
                .referenceDate(entity.getReferenceDate())
                .receivedAmount(entity.getReceivedAmount())

                // ✅ Names only if entities exist
                .supplierName(supplierEntity != null ? supplierEntity.getSupplierName() : null)
                .customerName(customerEntity != null ? customerEntity.getCustomerName() : null)

                // ✅ Balances safely default to 0
                .supplierCurrentBalance(entity.getSupplierCurrentBalance())
                .customerCurrentBalance(entity.getCustomerCurrentBalance())

                .slipNumber(entity.getSlipNumber())
                .drawType(entity.getDrawType())
                .remark(entity.getRemark())
                .build();
    }

}
