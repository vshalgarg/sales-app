import api from "../api/api";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

export const addPurchaseEntry = async (formData) => {
  try {
    const response = await api.post(`/purchase/entry/add`, formData);
    const result = checkLogicalError(response.data);
    return result;
  } catch (err) {
    throw new Error(handleApiError(err));
  }
};

export const searchPurchaseHistory = async (
  data,
  supplierId,
  customerId,
  page,
  rowsPerPage
) => {
  const { fromDate, toDate } = data;
  const size = rowsPerPage;
  try {
    const response = await api.get(`/purchase/entries/search`, {
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
