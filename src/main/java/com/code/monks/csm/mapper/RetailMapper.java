package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.RetailSupplierDepositEntity;
import com.code.monks.csm.entity.RetailSupplierEntity;
import com.code.monks.csm.entity.RetailerEntity;
import com.code.monks.csm.enums.StatusEnum;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.Comparator;
import java.util.List;

@Component
@Slf4j
public class RetailMapper {

    public RetailResponseDto toResponse(RetailerEntity retailer) {

        var staff = retailer.getStaff();
        var suppliers = retailer.getSuppliers()
                .stream()
                .map(s -> new RetailSupplierResponseDto(
                        s.getId(),
                        s.getSupplier().getId(),
                        s.getSupplier().getSupplierName(),
                        s.getSupplier().getCity(),
                        s.getTotalAmount(),
                        s.getDepositAmount(),
                        s.getBalanceAmount()

                ))
                .toList();

        return new RetailResponseDto(
                retailer.getId(),
                retailer.getName(),
                retailer.getDate(),
                retailer.getCustomer().getId(),
                retailer.getCustomer().getCustomerName(),
                staff != null ? staff.getId() : null,
                staff != null ? staff.getStaffName() : null,
                suppliers
        );
    }

    public RetailerListResponseDto toListDto(
            RetailerEntity retail
    ) {

        List<RetailSupplierResponseDto> suppliers =
                retail.getSuppliers()
                        .stream()
                        .filter(s -> s.getStatus() == StatusEnum.ACTIVE)
                        .map(supplier -> new RetailSupplierResponseDto(
                                supplier.getId(),
                                supplier.getSupplier().getId(),
                                supplier.getSupplier().getSupplierName(),
                                supplier.getSupplier().getCity(),
                                supplier.getTotalAmount(),
                                supplier.getDepositAmount(),
                                supplier.getBalanceAmount()
                        ))
                        .toList();

        return new RetailerListResponseDto(
                retail.getId(),
                retail.getName(),
                retail.getCustomer().getCustomerName(),
                retail.getStaff().getStaffName(),
                retail.getDate(),
                suppliers
        );
    }

    public SupplierDepositHistoryResponseDto mapSupplierDepositHistory(
            RetailSupplierEntity retailSupplier,
            List<RetailSupplierDepositEntity> deposits) {

        log.debug(
                "Mapping deposit history for supplier id : {}",
                retailSupplier.getSupplier().getId()
        );

        List<DepositHistoryDto> depositHistory =
                deposits.stream()
                        .sorted(Comparator.comparing(RetailSupplierDepositEntity::getDepositDate).reversed())
                        .map(deposit ->
                                DepositHistoryDto.builder()
                                        .date(deposit.getDepositDate())
                                        .amount(deposit.getAmount())
                                        .build()
                        )
                        .toList();

        return SupplierDepositHistoryResponseDto.builder()
                .retailSupplierId(retailSupplier.getId())
                .supplierId(retailSupplier.getSupplier().getId())
                .supplierName(retailSupplier.getSupplier().getSupplierName())
                .supplierCity(retailSupplier.getSupplier().getCity())
                .totalAmount(retailSupplier.getTotalAmount())
                .depositAmount(retailSupplier.getDepositAmount())
                .balanceAmount(retailSupplier.getBalanceAmount())
                .deposits(depositHistory)
                .build();
    }
}