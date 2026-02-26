package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Entity
@Table(name = "bill_detail")
@Getter
@Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class BillDetailEntity extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
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
