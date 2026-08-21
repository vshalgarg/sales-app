package com.code.monks.csm.entity;

import com.code.monks.csm.enums.MsmeEnum;
import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.enums.converter.StatusEnumConverter;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

@Entity
@Data
@EqualsAndHashCode(callSuper = true)
@Table(
        name = "customer",
        indexes = {
                @Index(name = "idx_customer_name", columnList = "name"),
                @Index(name = "idx_customer_gst", columnList = "gstNo"),
                @Index(name = "idx_customer_code", columnList = "code")
        }
)
public class CustomerEntity extends BaseEntity{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "code")
    private String code;

    @Column(name = "name")
    private String customerName;

    @Column(name = "email")
    private String email;

    @Column(name = "group_name")
    private String groupName;

    @Column(
            name = "gst_no",
            nullable = true
    )
    private String gstNo;

    @Column(name = "referenced_by")
    private String referencedBy;

    @Column(name = "address_line1")
    private String addressLine1;

    @Column(name = "address_line2")
    private String addressLine2;

    @Column(name = "state", length = 50)
    private String state;

    @Column(name = "city")
    private String city;

    @Column(name = "pin_code")
    private String pinCode;

    @Column(name = "msme")
    @Enumerated(EnumType.STRING)
    private MsmeEnum msme;


    @ManyToMany(fetch = FetchType.LAZY)
    @JoinTable(
            name = "customer_preferred_transport",
            joinColumns = @JoinColumn(name = "customer_id"),
            inverseJoinColumns = @JoinColumn(name = "transport_id")
    )
    private Set<TransportEntity> preferredTransports = new HashSet<>();

    @Column(name = "remark")
    private String remark;

    @Column(name = "status")
    private StatusEnum status;

    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<ContactEntity> contactList;

    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<BankDetailEntity> bankDetails;

}
