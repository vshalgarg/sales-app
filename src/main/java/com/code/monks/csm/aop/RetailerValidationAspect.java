package com.code.monks.csm.aop;

import com.code.monks.csm.exception.BusinessException;
import com.code.monks.csm.service.ConfigurationService;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import static com.code.monks.csm.enums.ResponseErrorCode.INVALID_CONFIGURATION_VALUE;

@Aspect
@Component
@RequiredArgsConstructor
public class RetailerValidationAspect {

    @Value("${feature.retail.config-key}")
    private String retailConfigKey;
    private final ConfigurationService configurationService;

    @Before(
            "@within(com.code.monks.csm.annotation.RetailerEnabled) || " +
                    "@annotation(com.code.monks.csm.annotation.RetailerEnabled)"
    )
    public void validateRetailerFeature() {

        Boolean enabled = configurationService.getBoolean(retailConfigKey);
        if (!enabled) {
            throw new BusinessException(INVALID_CONFIGURATION_VALUE);
        }
    }
}
