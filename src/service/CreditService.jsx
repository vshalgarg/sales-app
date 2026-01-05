import api from "../api/api";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

export const addCreditEntry = async (formData) => {
  try {
    const response = await api.post(`/credit/entry/add`, formData);
    const result = checkLogicalError(response.data);
    return result;
  } catch (checkLogicalError) {
      throw new Error(handleApiError(error));
  }
};

export const searchCreditHistory = async (
  data,
  supplierId,
  customerId,
  page,
  rowsPerPage
) => {
  const { fromDate, toDate } = data;
  const size = rowsPerPage;
  try {
    const response = await api.get(`/credit/entries/search`, {
      params: {
        fromDate,
        toDate,
        supplierId,
        customerId,
        page,
        size,
      },
    });
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
      throw new Error(handleApiError(error));
  }
};
