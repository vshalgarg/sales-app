package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "bank_detail")
@Getter
@Setter
public class BankDetailEntity extends BaseEntity {

      @Id
      @GeneratedValue(strategy = GenerationType.IDENTITY)
      private Integer id;

      @Column(name = "bank_name")
      private String bankName;

      @Column(name = "ifsc_code")
      private String ifscCode;

      @Column(name = "branch_name")
      private String branchName;

      @Column(name = "account_name")
      private String accountName;

      @Column(name = "account_number")
      private String accountNumber;

      @ManyToOne(fetch = FetchType.LAZY)
      @JoinColumn(name = "supplier_id")
      private SupplierEntity supplier;

      @ManyToOne(fetch = FetchType.LAZY)
      @JoinColumn(name = "customer_id")
      private CustomerEntity customer;
}