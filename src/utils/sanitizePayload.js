export const sanitizePayload = (obj) => {
  const sanitized = {};

  Object.keys(obj).forEach((key) => {
    const value = obj[key];

    if (Array.isArray(value)) {
      sanitized[key] = value;
    } else if (typeof value === "string") {
      sanitized[key] = value.trim() === "" ? null : value.trim();
    } else {
      sanitized[key] = value;
    }
  });

  return sanitized;
};