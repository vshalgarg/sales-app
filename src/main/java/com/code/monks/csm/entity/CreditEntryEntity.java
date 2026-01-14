package com.code.monks.csm.entity;

import com.code.monks.csm.enums.CreditEntryEnum;
import com.code.monks.csm.enums.DrawTypeEnum;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Entity
@Table(name = "credit")
@Data
@EqualsAndHashCode(callSuper = true)
public class CreditEntryEntity extends BaseEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "payment_type")
    private CreditEntryEnum paymentType;

    @Column(name = "bill_number")
    private String billNumber;

    @Column(name = "date")
    private LocalDate date;

    @Column(name = "reference_number")
    private String referenceNumber;

    @Column(name = "reference_date")
    private LocalDate referenceDate;

    @Column(name = "received_amount")
    private long receivedAmount;

    @Column(name = "supplier_current_balance")
    private long supplierCurrentBalance;

    @Column(name = "customer_current_balance")
    private long customerCurrentBalance;

    @Column(name = "draw_type")
    private DrawTypeEnum drawType;

    @Column(name = "remark")
    private String remark;

    @Column(name = "slip_number", length = 30)
    private String slipNumber;

    @Column(name = "supplier_id")
    private int supplierId;

    @Column(name = "customer_id")
    private int customerId;

}
