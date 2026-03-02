package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.List;
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

    @ManyToMany
    @JoinTable(
            name = "purchase_suppliers",
            joinColumns = @JoinColumn(name = "purchase_id"),
            inverseJoinColumns = @JoinColumn(name = "supplier_id")
    )
    private Set<SupplierEntity> suppliers = new HashSet<>();

    @ManyToOne
    @JoinColumn(name = "customer_id")
    private CustomerEntity customer;

    @Column(name = "purchase_amount")
    private Long purchaseAmount;

    @OneToMany(mappedBy = "purchase",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.EAGER
    )
    private List<PurchaseImageEntity> images;

}
