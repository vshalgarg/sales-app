package com.code.monks.csm.entity;

import jakarta.persistence.*;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@Entity
@Table(name = "purchase_images")
public class PurchaseImageEntity extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @EqualsAndHashCode.Include
    private Integer id;

    @Column(name = "object_key", nullable = false, length = 500)
    private String objectKey;

    @Column(name = "public_url", length = 500)
    private String publicUrl;

    @ManyToOne
    @JoinColumn(name = "purchase_id")
    private PurchaseEntity purchase;

    @Column(name = "original_file_name")
    private String originalFileName;
}

