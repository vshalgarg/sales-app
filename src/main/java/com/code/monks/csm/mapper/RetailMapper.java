package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.response.RetailResponseDto;
import com.code.monks.csm.dto.response.RetailSupplierResponseDto;
import com.code.monks.csm.dto.response.RetailerListResponseDto;
import com.code.monks.csm.entity.RetailSupplierEntity;
import com.code.monks.csm.entity.RetailerEntity;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class RetailMapper {

    public RetailResponseDto toResponse(RetailerEntity retailer) {

        var staff = retailer.getStaff();
        var suppliers = retailer.getSuppliers()
                .stream()
                .map(item -> new RetailSupplierResponseDto(
                        item.getSupplier().getId(),
                        item.getSupplier().getSupplierName(),
                        item.getBalanceAmount(),
                        item.getDepositAmount(),
                        item.getTotalAmount()
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
                        .map(supplier -> new RetailSupplierResponseDto(
                                supplier.getSupplier().getId(),
                                supplier.getSupplier().getSupplierName(),
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
}