import api from "../api/api";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

export const getAmountAndCountVsMonth = async (payload) => {
  try {
    const response = await api.post("/analytics/monthly ",payload);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const getStaffAnalytics = async (payload) => {
  try {
    const response = await api.post("/analytics/staff",payload);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const getSupplierVsAmount = async (payload) => {
  try {
    const response = await api.post("/analytics/supplier/amount", payload);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const getCustomerVsAmount = async (payload) => {
  try {
    const response = await api.post("/analytics/customer/amount", payload);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};