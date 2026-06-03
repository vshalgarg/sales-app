package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name = "retailers")
public class RetailerEntity extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    private String name;
    private LocalDate transactionDate;

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
