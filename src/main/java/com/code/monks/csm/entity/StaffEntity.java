package com.code.monks.csm.entity;

import com.code.monks.csm.enums.StatusEnum;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Entity
@Data
@EqualsAndHashCode(callSuper = true)
@Table(name = "staff")
public class StaffEntity extends BaseEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "name")
    private String staffName;

    @Column(name = "phone")
    private String phone;

    @Column(name = "joining_date")
    private LocalDate joiningDate;

    @Column(name = "status")
    private StatusEnum status;
}
