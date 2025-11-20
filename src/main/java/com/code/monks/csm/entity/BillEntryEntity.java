package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.aspectj.bridge.IMessage;

import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@Entity
@Table(name ="Bill")
public class BillEntryEntity extends BaseEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(name = "bill_number")
    private String billNumber;

    @Column(name = "date")
    private LocalDate date;

    @Column(name = "received_date")
    private LocalDate receivedDate;

    @Column(name = "orders")
    private String orders;

    @Column(name = "pieces")
    private int pieces;

    @Column(name = "gross_amount")
    private long grossAmount;

    @Column(name = "discount")
    private int discountPercent;

    @Column(name = "discount_amount")
    private long discountAmount;

    @Column(name = "gst_percentage")
    private int gstPercent;

    @Column(name = "gst_amount")
    private long gstAmount;

    @Column(name = "bill_amount")
    private long billAmount;

    @Column(name = "add_on_amount")
    private long addOnAmount;

    @Column(name = "taxable_value")
    private long taxableValue;

    @Column(name = "transport")
    private String transport;

    @Column(name = "lr_number")
    private String lrNumber;

    @Column(name = "ecr_amount")
    private double ecrAmount;

    @Column(name = "remarks")
    private String remarks;

    @Column(name = "supplier_id")
    private Integer supplierId;

    @Column(name = "customer_id")
    private Integer customerId;
}
