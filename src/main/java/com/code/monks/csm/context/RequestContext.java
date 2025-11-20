package com.code.monks.csm.context;

import com.code.monks.csm.dto.User;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class RequestContext {
    private static final ThreadLocal<User> tokenHolder = new ThreadLocal<>();

    public static void setUser(User user) {
        if (user == null) {
            log.warn("Attempting to set null user in RequestContext");
            throw new IllegalArgumentException("User cannot be null");
        }
        log.debug("Setting user in context: userId={}", user.getUserId());
        tokenHolder.set(user);
    }

    public static User getUser() {
        User user = tokenHolder.get();
        log.debug("Retrieved user from context: {}",
                user != null ? "userId=" + user.getUserId() : "null");
        return user;
    }

    public static User getRequiredUser() {
        User user = getUser();
        if (user == null) {
            log.error("No user found in request context");
            throw new IllegalStateException("No user found in request context.");
        }
        return user;
    }

    public static void clear() {
        User user = tokenHolder.get();
        if (user != null) {
            log.debug("Clearing user from context: userId={}", user.getUserId());
        }
        tokenHolder.remove();
    }
}
