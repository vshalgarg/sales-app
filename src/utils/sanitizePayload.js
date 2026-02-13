export const sanitizePayload = (obj) => {
  if (Array.isArray(obj)) {
    return obj.map(item => sanitizePayload(item));
  }

  if (obj !== null && typeof obj === "object") {
    const sanitized = {};
    Object.keys(obj).forEach((key) => {
      sanitized[key] = sanitizePayload(obj[key]);
    });
    return sanitized;
  }

  if (typeof obj === "string") {
    return obj.trim() === "" ? null : obj.trim();
  }

  return obj;
};
