package com.code.monks.csm.mapper;

import com.code.monks.csm.dto.response.CreditDetailResponse;
import com.code.monks.csm.entity.CreditEntryEntity;
import com.code.monks.csm.entity.CustomerEntity;
import com.code.monks.csm.entity.SupplierEntity;
import com.code.monks.csm.utils.MoneyUtil;
import org.springframework.stereotype.Component;

@Component
public class CreditMapper {

    public CreditDetailResponse toCreditDetail(CreditEntryEntity entity, CustomerEntity customer, SupplierEntity supplier) {
        return new CreditDetailResponse(
                entity.getId(),
                entity.getPaymentType(),
                entity.getBillNumber(),
                entity.getDate(),
                entity.getReferenceNumber(),
                entity.getReferenceDate(),
                MoneyUtil.toRupee(entity.getReceivedAmount()).doubleValue(),
                entity.getDrawType(),
                entity.getRemark(),
                entity.getSlipNumber(),
                entity.getSupplierId(),
                supplier != null ? supplier.getSupplierName() : null,
                supplier != null ? supplier.getCity() : null,
                entity.getCustomerId(),
                customer != null ? customer.getCustomerName() : null,
                customer != null ? customer.getCity() : null
        );
    }
}
