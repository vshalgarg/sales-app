import api from "../api/api";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

export const addBill = async (billData) => {
  try {
    const response = await api.post("/bill/entry/add", billData);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const getBillHistory = async () => {
  try {
    const response = await api.get(`/bill/entries/get`);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

// api.js already has axios instance configured
export const updateBillApi = async (billNumber, updates) => {
  try {
    const response = await api.patch(
      `/bill/entry/update/${billNumber}`,
      updates
    );
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
   throw new Error(handleApiError(error));
  }
};

export const searchBillHistory = async (data, page, rowsPerPage) => {
  const { fromDate, toDate, supplierId, customerId } = data;
  try {
   const response = await api.get("/bill/entries/search", {
    params: {
      fromDate,
      toDate,
      supplierId,
      customerId,
      page,
      size: rowsPerPage,
    },
  });
const result = checkLogicalError(response.data);

    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const searchTransports = async (query) => {
  if (!query || query.trim().length < 1) {
    return [];
  }

  try {
    const response = await api.get("/transports/search", {
      params: { query: query.trim() }
    });
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};
