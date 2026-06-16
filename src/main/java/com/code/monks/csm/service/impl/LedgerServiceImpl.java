package com.code.monks.csm.service.impl;

import com.code.monks.csm.dto.ledger.LedgerEntryDto;
import com.code.monks.csm.dto.ledger.LedgerPartyDto;
import com.code.monks.csm.dto.ledger.LedgerResponseDto;
import com.code.monks.csm.entity.BillEntryEntity;
import com.code.monks.csm.entity.CreditEntryEntity;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.enums.LedgerViewTypeEnum;
import com.code.monks.csm.enums.ResponseErrorCode;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.repository.BillEntryRepo;
import com.code.monks.csm.repository.CreditEntryRepo;
import com.code.monks.csm.repository.CustomerRepo;
import com.code.monks.csm.repository.SupplierRepo;
import com.code.monks.csm.service.LedgerService;
import com.code.monks.csm.utils.MoneyUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
@RequiredArgsConstructor
@Slf4j
public class LedgerServiceImpl implements LedgerService {

    private final BillEntryRepo billEntryRepository;
    private final CreditEntryRepo creditEntryRepository;
    private final CustomerRepo customerRepository;
    private final SupplierRepo supplierRepository;

    @Override
    public LedgerResponseDto getLedger(Integer supplierId, Integer customerId, LedgerViewTypeEnum ledgerType) {

        log.info("Fetching ledger for supplierId={}, customerId={}, ledgerType={}", supplierId, customerId, ledgerType);

        LedgerPartyDto party = getPartyDetails(supplierId, customerId, ledgerType);
        List<LedgerEntryDto> entries = getLedgerEntries(supplierId, customerId, ledgerType);

        entries = calculateRunningBalance(entries, ledgerType);

        BigDecimal totalDebit = calculateTotalDebit(entries);
        BigDecimal totalCredit = calculateTotalCredit(entries);

        BigDecimal balance = calculateBalance(totalDebit, totalCredit);

        log.info("Ledger generated successfully. Entries={}, TotalDebit={}, TotalCredit={}, Balance={}", entries.size(), totalDebit, totalCredit, balance);

        return LedgerResponseDto.builder()
                .party(party)
                .ledgerType(ledgerType)
                .totalDebit(totalDebit)
                .totalCredit(totalCredit)
                .balance(balance)
                .entries(entries)
                .build();
    }


    private LedgerPartyDto getPartyDetails(Integer supplierId, Integer customerId, LedgerViewTypeEnum ledgerType) {

        log.debug("Fetching party details for ledgerType={}", ledgerType);

        return switch (ledgerType) {
            case CUSTOMER ->
                    getSupplierDetails(supplierId);

            case SUPPLIER ->
                    getCustomerDetails(customerId);
        };
    }

    private LedgerPartyDto getCustomerDetails(Integer customerId) {

        CustomerEntity customer = customerRepository
                .findById(customerId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                ResponseErrorCode.CUSTOMER_NOT_FOUND, " "+ customerId
                        ));
        String mobile = customer.getContactList().isEmpty()
                ? null
                : customer.getContactList()
                .get(customer.getContactList().size() - 1)
                .getMobileNumber();

        String address = Stream.of(
                        customer.getAddressLine1(),
                        customer.getAddressLine2()
                )
                .filter(Objects::nonNull)
                .filter(s -> !s.isBlank())
                .collect(Collectors.joining(", "));

        return LedgerPartyDto.builder()
                .id(customer.getId())
                .name(customer.getCustomerName())
                .email(customer.getEmail())
                .phone(mobile)
                .gstNo(customer.getGstNo())
                .address(address)
                .build();
    }

    private LedgerPartyDto getSupplierDetails(Integer supplierId) {

        SupplierEntity supplier = supplierRepository
                .findById(supplierId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                               ResponseErrorCode.SUPPLIER_NOT_FOUND," " +supplierId
                        ));

        String mobile = supplier.getContactList().isEmpty()
                ? null
                : supplier.getContactList()
                .get(supplier.getContactList().size() - 1)
                .getMobileNumber();
        String address = Stream.of(
                        supplier.getAddressLine1(),
                        supplier.getAddressLine2()
                )
                .filter(Objects::nonNull)
                .filter(s -> !s.isBlank())
                .collect(Collectors.joining(", "));

        return LedgerPartyDto.builder()
                .id(supplier.getId())
                .name(supplier.getSupplierName())
                .email(supplier.getEmail())
                .phone(mobile)
                .gstNo(supplier.getGstNo())
                .address(address)
                .build();
    }


    private List<LedgerEntryDto> getBillEntries(Integer supplierId, Integer customerId, LedgerViewTypeEnum ledgerType) {

        List<LedgerEntryDto> billEntries = billEntryRepository.findBySupplier_IdAndCustomer_Id(supplierId, customerId)
                .stream()
                .map(bill -> mapBillToLedgerEntry(bill, ledgerType))
                .toList();

        log.debug("Fetched {} bill entries", billEntries.size());
        return billEntries;
    }

    private List<LedgerEntryDto> getCreditEntries(
            Integer supplierId,
            Integer customerId,
            LedgerViewTypeEnum ledgerType
    ) {

        List<LedgerEntryDto> creditEntries = creditEntryRepository
                .findBySupplierIdAndCustomerId(
                        supplierId,
                        customerId
                )
                .stream()
                .map(credit -> mapCreditToLedgerEntry(
                        credit,
                        ledgerType
                ))
                .toList();

        log.debug(
                "Fetched {} credit entries",
                creditEntries.size()
        );

        return creditEntries;
    }

    private List<LedgerEntryDto> getLedgerEntries(Integer supplierId, Integer customerId, LedgerViewTypeEnum ledgerType) {

        log.debug("Preparing ledger entries for supplierId={}, customerId={}", supplierId, customerId);
        List<LedgerEntryDto> entries = new ArrayList<>();

        entries.addAll(getBillEntries(supplierId, customerId, ledgerType));
        entries.addAll(getCreditEntries(supplierId, customerId, ledgerType)
        );

        entries.sort(Comparator.comparing(LedgerEntryDto::date));
        log.debug("Total merged ledger entries={}", entries.size());

        return entries;
    }

    private LedgerEntryDto mapCreditToLedgerEntry(CreditEntryEntity creditEntry, LedgerViewTypeEnum ledgerType) {

        BigDecimal debit = BigDecimal.ZERO;
        BigDecimal credit = BigDecimal.ZERO;

        BigDecimal amount = MoneyUtil.toRupee(creditEntry.getReceivedAmount());

        if (ledgerType == LedgerViewTypeEnum.CUSTOMER) {
            debit = amount;
        } else {
            credit = amount;
        }

        return new LedgerEntryDto(
                creditEntry.getDate(),
                creditEntry.getBillNumber(),
                creditEntry.getPaymentType().name(),
                debit,
                credit,
                null
        );
    }

    private LedgerEntryDto mapBillToLedgerEntry(BillEntryEntity bill, LedgerViewTypeEnum ledgerType) {

        BigDecimal debit = BigDecimal.ZERO;
        BigDecimal credit = BigDecimal.ZERO;
        BigDecimal amount = MoneyUtil.toRupee(bill.getBillAmount());

        if (ledgerType == LedgerViewTypeEnum.CUSTOMER) {
            credit = amount;
        } else {
            debit = amount;
        }

        return new LedgerEntryDto(
                bill.getDate(),
                bill.getInvoiceNo(),
                "Bill",
                debit,
                credit,
                null
        );
    }

    private List<LedgerEntryDto> calculateRunningBalance(List<LedgerEntryDto> entries, LedgerViewTypeEnum ledgerType) {

        log.debug("Calculating running balance for {} entries", entries.size());

        BigDecimal balance = BigDecimal.ZERO;
        List<LedgerEntryDto> result = new ArrayList<>();

        for (LedgerEntryDto entry : entries) {

            if (ledgerType == LedgerViewTypeEnum.CUSTOMER) {
                balance = balance.add(entry.credit()).subtract(entry.debit());
            } else {
                balance = balance.add(entry.credit()).subtract(entry.debit());
            }

            result.add(
                    new LedgerEntryDto(
                            entry.date(),
                            entry.invoiceNo(),
                            entry.particular(),
                            entry.debit(),
                            entry.credit(),
                            balance
                    )
            );
        }

        return result;
    }

    private BigDecimal calculateTotalDebit(List<LedgerEntryDto> entries){
        return entries.stream()
                .map(LedgerEntryDto::debit)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal calculateTotalCredit(List<LedgerEntryDto> entries){
        return entries.stream()
                .map(LedgerEntryDto::credit)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private BigDecimal calculateBalance(BigDecimal totalDebit, BigDecimal totalCredit) {
        return totalCredit.subtract(totalDebit);
    }
}
