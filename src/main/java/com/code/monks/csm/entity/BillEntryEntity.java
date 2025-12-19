package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter@Setter
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name ="Bill")
public class BillEntryEntity extends BaseEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "bill_number")
    private String billNumber;

    private LocalDate date;
    private LocalDate receivedDate;
    private String orders;

    @Column(name = "taxable_value")
    private double taxableValue;

    @Column(name = "bill_amount")
    private double billAmount;

    @Column(name = "transport_id")
    private Integer transportId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "transport_id", insertable = false, updatable = false)
    private TransportEntity transportEntity;

    private String lrNumber;
    private String remarks;

    @Column(name = "supplier_id")
    private Integer supplierId;

    @Column(name = "customer_id")
    private Integer customerId;

    // One bill header has many items
    @OneToMany(mappedBy = "billEntry", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<BillDetailEntity> billDetails = new ArrayList<>();
}
