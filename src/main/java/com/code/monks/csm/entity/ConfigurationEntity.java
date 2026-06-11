package com.code.monks.csm.entity;

import com.code.monks.csm.enums.ConfigurationTypeEnum;
import com.code.monks.csm.enums.converter.ConfigurationTypeEnumConverter;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "configurations")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConfigurationEntity extends BaseEntity{

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(name = "config_key", unique = true, nullable = false)
    private String configKey;

    @Column(name = "config_value")
    private String configValue;

    @Column(name = "config_type")
    @Convert(converter = ConfigurationTypeEnumConverter.class)
    private ConfigurationTypeEnum type;

    private String description;
}
