package com.code.monks.csm.entity;

import com.code.monks.csm.enums.StatusEnum;
import com.code.monks.csm.enums.converter.StatusEnumConverter;
import jakarta.persistence.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter@Setter
@Entity
@Table(
        name = "transports",
        uniqueConstraints = {
                @UniqueConstraint(columnNames = "contact_number"),
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

    @Column(name = "gst_no")
    private String gstNo;

    @Column(name = "contact_number", nullable = false)
    private String contactNumber;

    @Column(name = "city")
    private String city;

    @Column(name = "address", nullable = false)
    private String address;

    @Column(name = "status")
    private StatusEnum status;
}
