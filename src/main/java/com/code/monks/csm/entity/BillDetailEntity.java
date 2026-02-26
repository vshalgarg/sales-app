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
    private long grossAmount;
    private int discountPercent;
    private long discountAmount;
    private long addOnAmount;
    private long ecrAmount;
    private int gstPercent;
    private long gstAmount;

    @ManyToOne
    @JoinColumn(name = "bill_Entry_id")
    private BillEntryEntity billEntry;

}
