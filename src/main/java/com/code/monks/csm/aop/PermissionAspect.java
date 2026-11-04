package com.code.monks.csm.aop;

import com.code.monks.csm.annotation.HasPermission;
import com.code.monks.csm.context.RequestContext;
import com.code.monks.csm.exception.PermissionDeniedException;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.stereotype.Component;

import java.util.List;

import static com.code.monks.csm.enums.ResponseErrorCode.PERMISSION_DENIED;

@Aspect
@Component
public class PermissionAspect {

    @Before("@annotation(hasPermission)")
    public void checkPermission(HasPermission hasPermission){
        String requiredPermission = hasPermission.value();

        List<String> userPermissions = RequestContext.getUser().getPermissions();

        if (userPermissions == null || !userPermissions.contains(requiredPermission)) {
            throw new PermissionDeniedException(PERMISSION_DENIED);
        }
    }
}
