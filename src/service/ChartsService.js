import api from "../api/api";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

export const getAmountAndCountVsMonth = async (payload) => {
  try {
    const response = await api.post("/analytics/amount-vs-month ",payload);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};