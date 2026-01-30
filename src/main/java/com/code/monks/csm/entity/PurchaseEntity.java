package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

@Entity
@Table(name = "purchase")
@Data
@EqualsAndHashCode(callSuper = true)
public class PurchaseEntity extends BaseEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "date", nullable = false)
    private LocalDate date;

    @Column(name = "staff_id")
    private Integer staffId;

    @Column(name = "supplier_id")
    private Integer supplierId;

    @ManyToMany
    @JoinTable(
            name = "purchase_customers",
            joinColumns = @JoinColumn(name = "purchase_id"),
            inverseJoinColumns = @JoinColumn(name = "customer_id")
    )
    private Set<CustomerEntity> customers = new HashSet<>();

    @Column(name = "purchase_amount")
    private Long purchaseAmount;
}
