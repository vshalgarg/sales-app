package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.response.RetailResponseDto;
import com.code.monks.csm.dto.response.RetailSupplierResponseDto;
import com.code.monks.csm.entity.RetailerEntity;
import org.springframework.stereotype.Component;

@Component
public class RetailMapper {

    public RetailResponseDto toResponse(RetailerEntity retailer) {

        var staff = retailer.getStaff();
        var suppliers = retailer.getSuppliers()
                .stream()
                .map(item -> new RetailSupplierResponseDto(
                        item.getSupplier().getId(),
                        item.getSupplier().getSupplierName(),
                        item.getAmount()
                ))
                .toList();

        return new RetailResponseDto(
                retailer.getId(),
                retailer.getName(),
                retailer.getCustomer().getId(),
                retailer.getCustomer().getCustomerName(),
                staff != null ? staff.getId() : null,
                staff != null ? staff.getStaffName() : null,
                retailer.getDepositAmount(),
                retailer.getBalanceAmount(),
                suppliers
        );
    }
}