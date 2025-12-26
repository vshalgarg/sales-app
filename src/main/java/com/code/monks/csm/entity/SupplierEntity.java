package com.code.monks.csm.entity;

import com.code.monks.csm.enums.StatusEnum;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Entity
@Data
@EqualsAndHashCode(callSuper = true)
@Table(
        name = "supplier",
        indexes = {
                @Index(name = "idx_supplier_name", columnList = "name"),
                @Index(name = "idx_supplier_gst", columnList = "gstNo"),
                @Index(name = "idx_supplier_code", columnList = "code") // optional
        }
)
public class SupplierEntity extends BaseEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "code")
    private String code;

    @Column(name = "name")
    private String supplierName;

    @Column(name = "group_name")
    private String groupName;

    @Column(name = "gst_no")
    private String gstNo;

    @Column(name = "commission_scheme")
    private String commissionScheme;

    @Column(name = "commission_rate")
    private double commissionRate;

    @Column(name = "address_line1")
    private String addressLine1;

    @Column(name = "address_line2")
    private String addressLine2;

    @Column(name = "city")
    private String city;

    @Column(name = "pin_code")
    private String pinCode;

    @Column(name = "msme")
    private String msme;

    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "supplier_preferred_transport",
            joinColumns = @JoinColumn(name = "supplier_id"),
            inverseJoinColumns = @JoinColumn(name = "transport_id")
    )
    private Set<TransportEntity> preferredTransports = new LinkedHashSet<>();

    @Column(name = "remark")
    private String remark;

    @Column(name = "status")
    private StatusEnum status;

    @OneToMany(mappedBy = "supplier", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<ContactEntity> contactList;

}
