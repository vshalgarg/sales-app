package com.code.monks.csm.service.impl;

import com.code.monks.csm.entity.ConfigurationEntity;
import com.code.monks.csm.enums.ConfigurationTypeEnum;
import com.code.monks.csm.exception.BusinessException;
import com.code.monks.csm.exception.ResourceNotFoundException;
import com.code.monks.csm.repository.ConfigurationRepository;
import com.code.monks.csm.service.ConfigurationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import static com.code.monks.csm.enums.ResponseErrorCode.CONFIGURATION_NOT_FOUND;
import static com.code.monks.csm.enums.ResponseErrorCode.INVALID_CONFIGURATION_VALUE;

@Service
@RequiredArgsConstructor
public class ConfigurationServiceImpl implements ConfigurationService {

    private final ConfigurationRepository configurationRepository;

    @Override
    public Boolean getBoolean(String key) {

        ConfigurationEntity config = getConfiguration(key);

        if (config == null) {
            return true;
        }
        if (config.getType() != ConfigurationTypeEnum.BOOLEAN) {
            throw new BusinessException(INVALID_CONFIGURATION_VALUE);
        }

        return Boolean.parseBoolean(config.getConfigValue());
    }

    private ConfigurationEntity getConfiguration(String key) {
        return configurationRepository
                .findByConfigKey(key)
                .orElse(null);
    }
}
