import api from "../api/api";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

export const addRetailEntry = async (formData) => {
  try {
    const response = await api.post(`/retail/create`, formData);
    const result = checkLogicalError(response.data);
    return result;
  } catch (err) {
    throw new Error(handleApiError(err));
  }
};

export const searchRetailerHistory = async (
  filterObject,
  page,
  rowsPerPage,
) => {
  const { fromDate, toDate, supplierId, customerId, staffId } = filterObject;
  try {
    const response = await api.get("/retail/search", {
      params: {
        fromDate,
        toDate,
        supplierId: supplierId ?? null,
        customerId: customerId ?? null,
        staffId: staffId ?? null,
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

export const updateRetailer = async (retailId, payload) => {
  try {
    const response = await api.put(`/retail/${retailId}`, payload);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const addDeposits = async (payload) => {
  try {
    const response = await api.post(`/retail-supplier-deposits`, {
      deposits: payload,
    });
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const deleteRetailer = async (id) => {
  try {
    const response = await api.delete(`/retail/${id}`);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const deleteSupplierPerRetailer = async (id) => {
  try {
    const response = await api.delete(`/retail-suppliers/${id}`);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const getRetailerDetailsById = async (id) => {
  try {
    const response = await api.get(`/retail/get/${id}`);

    const result = checkLogicalError(response.data);

    return result.data;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const getSupplierAndPaymentHistory = async (id) => {
  try {
    const response = await api.get(`/retail/${id}/deposits`);

    const result = checkLogicalError(response.data);

    return result.data;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const updateSupplier = async (retailSupplierId, payload) => {
  try {
    const response = await api.put(
      `retail-suppliers/${retailSupplierId}`,
      payload,
    );
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const addSupplierToRetailer = async (formData) => {
  try {
    const response = await api.post(`/retail-suppliers`, formData);
    const result = checkLogicalError(response.data);
    return result;
  } catch (err) {
    throw new Error(handleApiError(err));
  }
};
