package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import static jakarta.persistence.CascadeType.ALL;

@Getter@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name ="bill")
public class BillEntryEntity extends BaseEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "bill_number")
    private String billNumber;

    private LocalDate date;
    private LocalDate receivedDate;

    @Column(name = "invoice_no")
    private String invoiceNo;

    @Column(name = "taxable_value")
    private Long taxableValue;

    @Column(name = "bill_amount")
    private Long billAmount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "transport_id")
    private TransportEntity transportEntity;

    private String lrNumber;
    private String remarks;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "supplier_id", nullable = false)
    private SupplierEntity supplier;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private CustomerEntity customer;

    // One bill header has many items
    @OneToMany(mappedBy = "billEntry", cascade = ALL, orphanRemoval = true)
    private List<BillDetailEntity> billDetails = new ArrayList<>();

    @OneToMany(mappedBy = "billEntry", cascade = ALL, orphanRemoval = true)
    private List<BillImageEntity> images;
}
