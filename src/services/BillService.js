import api from "../api/api";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

export const addBill = async (billData) => {
  try {
    const response = await api.post("/bill/entry/add", billData, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const getBillDetails = async (billNumber) => {
  try {
    const response = await api.get(`/bill/${billNumber}`);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

// api.js already has axios instance configured
export const updateBillApi = async (billNumber, formData) => {
  try {
    const response = await api.patch(
      `/bill/entry/update/${billNumber}`,
      formData,
      {
        headers: {
          "Content-Type": "multipart/form-data",
        },
      }
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

export const deleteBill = async (billNumber) => {
  try {
    const response = await api.delete(
      `/bill/entry/delete/${billNumber}`
    );
    const result = checkLogicalError(response.data);
    return result;
  }
  catch (error) {
    throw new Error(handleApiError(error));
  }
};

