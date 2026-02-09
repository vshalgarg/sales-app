package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
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
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
public class TransportContactEntity extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Integer id;

    @Column(name = "contact_person", length = 100)
    private String contactPerson;

    @Column(name = "contact_number")
    private String contactNumber;

    @Column(name = "type", length = 50)
    private String type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "transport_id", nullable = false)
    private TransportEntity transport;
}
