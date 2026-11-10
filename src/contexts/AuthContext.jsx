import React, { createContext, useContext, useEffect, useState, useCallback,
} from "react";
import { useNavigate } from "react-router-dom";
import { useSnackbar } from "./SnackbarContext";

const AuthContext = createContext();

const getStoredArray = (key) => {
  try {
    const value = JSON.parse(localStorage.getItem(key) || "[]");
    return Array.isArray(value) ? value : [];
  } catch {
    return [];
  }
};

export const AuthProvider = ({ children }) => {
  const navigate = useNavigate();
  const { showSnackbar } = useSnackbar();

  const [auth, setAuth] = useState(() => {
    const token = localStorage.getItem("token");
    const role = getStoredArray("role");
    const permissions = getStoredArray("permissions");
    const userId = localStorage.getItem("userId");
    const username = localStorage.getItem("username");

    return token && role.length > 0
      ? {
          token,
          role,
          userId,
          username,
          permissions,
        }
      : null;
  });

  // Check whether the logged-in user has a permission
  const can = useCallback(
    (requiredPermission) => {
      return (
        Array.isArray(auth?.permissions) &&
        auth.permissions.includes(requiredPermission)
      );
    },
    [auth?.permissions]
  );

  // Check whether the user has at least one permission
  const canAny = useCallback(
    (requiredPermissions) => {
      return (
        Array.isArray(requiredPermissions) &&
        requiredPermissions.some((permission) => can(permission))
      );
    },
    [can]
  );

  // Check whether the user has all permissions
  const canAll = useCallback(
    (requiredPermissions) => {
      return (
        Array.isArray(requiredPermissions) &&
        requiredPermissions.every((permission) => can(permission))
      );
    },
    [can]
  );

  useEffect(() => {
    const onAppLogout = (event) => {
      console.log("Received logout event", event.detail);

      localStorage.clear();
      setAuth(null);

      navigate("/", { replace: true });
      showSnackbar("Session expired! login again", "error");
    };

    window.addEventListener("app:logout", onAppLogout);

    return () => {
      window.removeEventListener("app:logout", onAppLogout);
    };
  }, [navigate, showSnackbar]);

  const login = ({
    token,
    role,
    roles,
    userId,
    username,
    permissions = [],
  }) => {
    // Support both the existing "role" and API's "roles" property
    const normalizedRole = role ?? roles ?? [];

    localStorage.setItem("token", token);
    localStorage.setItem("role", JSON.stringify(normalizedRole));
    localStorage.setItem("userId", String(userId));
    localStorage.setItem("username", String(username));
    localStorage.setItem("permissions", JSON.stringify(Array.isArray(permissions) ? permissions : []));

    setAuth({
      token,
      role: normalizedRole,
      userId,
      username,
      permissions: Array.isArray(permissions) ? permissions : [],
    });
  };

  const logout = () => { 
    localStorage.clear();
    setAuth({
      token: null,
      role: null,
      userId: null,
      username: null,
      permissions: [],
    });
  };

  return (
    <AuthContext.Provider
      value={{
        auth,
        login,
        logout,
        setAuth,
        can,
        canAny,
        canAll,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
