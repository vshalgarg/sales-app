package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Entity
@Table(
        name = "transport_contacts",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_tc_transport_contact",
                        columnNames = {"transport_id", "contact_number"}
                )
        },
        indexes = {
                @Index(name = "idx_tc_contact_number", columnList = "contact_number"),
                @Index(name = "idx_tc_transport_id", columnList = "transport_id")
        }
)
public class TransportContactEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "contact_person", length = 100)
    private String contactPerson;

    @Column(name = "contact_number", nullable = false, length = 15)
    private String contactNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "transport_id", nullable = false)
    private TransportEntity transport;
}
