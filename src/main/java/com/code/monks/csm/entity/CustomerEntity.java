package com.code.monks.csm.entity;

import com.code.monks.csm.enums.StatusEnum;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;

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

    @Column(name = "group_name")
    private String groupName;

    @Column(name = "gst_no")
    private String gstNo;

    @Column(name = "referenced_by")
    private String referencedBy;

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

    @Column(name = "preferred_transport")
    private String[] preferredTransport;

    @Column(name = "remark")
    private String remark;

    @Column(name = "status")
    private StatusEnum status;

    @OneToMany(mappedBy = "customer", cascade = CascadeType.ALL)
    private List<ContactEntity> contactList;

}
