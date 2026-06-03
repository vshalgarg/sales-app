package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@Entity
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@Table(name = "retail_supplier")
public class RetailSupplierEntity extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne
    @JoinColumn(name = "retail_id")
    private RetailerEntity retail;

    @ManyToOne
    @JoinColumn(name = "supplier_id")
    private SupplierEntity supplier;

    private Long totalAmount;
    private Long depositAmount;
    private Long balanceAmount;
}
