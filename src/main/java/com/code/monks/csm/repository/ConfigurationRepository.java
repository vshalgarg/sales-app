package com.code.monks.csm.repository;

import com.code.monks.csm.entity.ConfigurationEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ConfigurationRepository extends JpaRepository<ConfigurationEntity, Integer> {

    Optional<ConfigurationEntity> findByConfigKey(String key);
}
