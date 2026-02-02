package com.code.monks.csm.entity;

import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.enums.converter.StatusEnumConverter;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter@Setter
@Entity
@Table(
        name = "transports",
        uniqueConstraints = {
                @UniqueConstraint(columnNames = "email"),
                @UniqueConstraint(columnNames = "gst_no")
        }
)
@EqualsAndHashCode(callSuper = true)
public class TransportEntity extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(name = "email", nullable = true)
    private String email;

    @Column(name = "gst_no", nullable = true)
    private String gstNo;

    @Column(name = "state", length = 50)
    private String state;

    @Column(name = "city")
    private String city;

    @Column(name = "pin_code")
    private String pinCode;

    @Column(name = "address_line1", nullable = false)
    private String addressLine1;

    @Column(name = "address_line2")
    private String addressLine2;

    @Column(name = "status")
    private StatusEnum status;

    @OneToMany(
            mappedBy = "transport",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private List<TransportContactEntity> contacts;
}
