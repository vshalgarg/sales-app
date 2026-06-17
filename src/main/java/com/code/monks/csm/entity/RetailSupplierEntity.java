package com.code.monks.csm.entity;

import com.code.monks.csm.enums.StatusEnum;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Set;

@Getter
@Setter
@Entity
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode(callSuper = true)
@Table(name = "retail_supplier")
@Builder
public class RetailSupplierEntity extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "retail_id")
    private RetailerEntity retail;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "supplier_id")
    private SupplierEntity supplier;

    private Long totalAmount;
    private Long depositAmount;
    private Long balanceAmount;
    private StatusEnum status;

    @OneToMany(
            mappedBy = "retailSupplier",
            cascade = CascadeType.ALL,
            orphanRemoval = true
    )
    private List<RetailSupplierDepositEntity> deposits;
}
