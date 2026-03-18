import dayjs from "dayjs";
import customParseFormat from "dayjs/plugin/customParseFormat";

dayjs.extend(customParseFormat);

// state → dayjs (for UI)
export const parseDate = (date) => {
  if (!date) return null;
  const parsed = dayjs(date, "YYYY-MM-DD", true);
  return parsed.isValid() ? parsed : null;
};

// dayjs → state/backend
export const formatDate = (date) => {
  return date ? dayjs(date).format("YYYY-MM-DD") : "";
};