export const hasPermission = (userPermissions, requiredPermission) => {
  return (
    Array.isArray(userPermissions) &&
    userPermissions.includes(requiredPermission)
  );
};

export const hasAnyPermission = (userPermissions, requiredPermissions) => {
  return (
    Array.isArray(requiredPermissions) &&
    requiredPermissions.some((permission) =>
      hasPermission(userPermissions, permission)
    )
  );
};

export const hasAllPermissions = (userPermissions, requiredPermissions) => {
  return (
    Array.isArray(requiredPermissions) &&
    requiredPermissions.every((permission) =>
      hasPermission(userPermissions, permission)
    )
  );
};
