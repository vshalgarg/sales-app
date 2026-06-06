package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.response.*;
import com.code.monks.csm.entity.*;
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
                .map(s -> {
                    SupplierEntity supplier = s.getSupplier();
                    return new RetailSupplierResponseDto(
                            s.getId(),
                            supplier != null ? supplier.getId() : null,
                            supplier != null ? supplier.getSupplierName() : null,
                            supplier != null ? supplier.getCity() : null,
                            s.getTotalAmount(),
                            s.getDepositAmount(),
                            s.getBalanceAmount()
                    );
                })
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
        StaffEntity staff = retail.getStaff();
        List<RetailSupplierResponseDto> suppliers =
                retail.getSuppliers()
                        .stream()
                        .filter(s -> s.getStatus() == StatusEnum.ACTIVE)
                        .map(supplier -> {
                            SupplierEntity supplierEntity = supplier.getSupplier();
                            return new RetailSupplierResponseDto(
                                    supplier.getId(),
                                    supplierEntity != null ? supplierEntity.getId() : null,
                                    supplierEntity != null ? supplierEntity.getSupplierName() : null,
                                    supplierEntity != null ? supplierEntity.getCity() : null,
                                    supplier.getTotalAmount(),
                                    supplier.getDepositAmount(),
                                    supplier.getBalanceAmount()
                            );
                        })
                        .toList();

        return new RetailerListResponseDto(
                retail.getId(),
                retail.getName(),
                retail.getCustomer().getCustomerName(),
                staff != null ? staff.getStaffName() : null,
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
        SupplierEntity supplier = retailSupplier.getSupplier();
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
                .supplierId(supplier != null ? supplier.getId() : null)
                .supplierName(supplier != null ? supplier.getSupplierName() : null)
                .supplierCity(supplier != null ? supplier.getCity() : null)
                .totalAmount(retailSupplier.getTotalAmount())
                .depositAmount(retailSupplier.getDepositAmount())
                .balanceAmount(retailSupplier.getBalanceAmount())
                .deposits(depositHistory)
                .build();
    }
}