package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "bill_detail")
@Data
public class BillDetailEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private int pieces;
    private double grossAmount;
    private int discountPercent;
    private double discountAmount;
    private double addOnAmount;
    private double ecrAmount;
    private int gstPercent;
    private double gstAmount;

    @ManyToOne
    @JoinColumn(name = "bill_Entry_id")
    private BillEntryEntity billEntry;
}
