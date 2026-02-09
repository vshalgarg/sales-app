package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "contact",
        indexes = {
                @Index(name = "idx_contact_mobile", columnList = "mobile_number"),
                @Index(name = "idx_contact_phone", columnList = "phone"),
                @Index(name = "idx_contact_supplier", columnList = "supplier_id"),
                @Index(name = "idx_contact_customer", columnList = "customer_id")
        }
)
@Getter
@Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class ContactEntity extends BaseEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Exclude
    private int id;

    @Column(name = "person")
    private String contactPerson;

    @Column(name = "mobile_number")
    private String mobileNumber;

    @Column(name = "type", length = 50)
    private String type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "supplier_id",nullable = true)
    @ToString.Exclude
    private SupplierEntity supplier;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id",nullable = true)
    @ToString.Exclude
    private CustomerEntity customer;

}
