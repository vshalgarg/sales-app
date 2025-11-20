package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Entity
@Table(name = "purchase")
@Data
@EqualsAndHashCode(callSuper = true)
public class PurchaseEntity extends BaseEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "date")
    private LocalDate date;

    @Column(name = "staff_id")
    private int staffId;

    @Column(name = "supplier_id")
    private int supplierId;

    @Column(name = "customer_id")
    private int customerId;

    @Column(name = "purchase_amount")
    private long purchaseAmount;
}
