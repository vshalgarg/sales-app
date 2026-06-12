import api from "../api/api";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

export const getLedger = async (payload) => {
  try {
    const response = await api.get("/ledger", {
      params: {
        supplierId: payload?.supplierId,
        customerId: payload?.customerId,
        viewType: payload?.viewType,
      },
    });
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const downloadLedger = async (payload) => {
  const response = await api.get("/ledger/download", {
    params: payload,
    responseType: "blob",
  });

  return response;
};
