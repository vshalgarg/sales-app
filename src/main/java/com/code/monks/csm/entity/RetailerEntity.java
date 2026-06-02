package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "retailers")
public class RetailerEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String name;
    private Long depositAmount;
    private Long balanceAmount;

    @ManyToOne
    @JoinColumn(name = "customer_id")
    private CustomerEntity customer;

    @ManyToOne
    @JoinColumn(name = "staff_id")
    private StaffEntity staff;

    @OneToMany(
            mappedBy = "retail",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<RetailSupplierEntity> suppliers;
}
