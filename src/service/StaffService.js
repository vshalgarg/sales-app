import api from "../api/api";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

export const saveStaff = async (staffData) => {
  try {
    const response = await api.post(`/staff/add`, staffData);
    const result = checkLogicalError(response.data);
    return result
  } catch (error) {
   throw new Error(handleApiError(error));
  }
};

export const getStaffs = async (page = 1, size = 5) => {
  try {
    const response = await api.get(`/staffs/get`, {
      params: {
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

export const searchStaffs = async (keyword,page=0,size=10) => {
  try {
    const response = await api.get(`/staffs/search`, { 
      params: {
         keyword,
         page,
         size

        } });
        const result = checkLogicalError(response.data);
    return result; 
  } catch (error) {
   throw new Error(handleApiError(error));
  }
};

export const getAllActiveStaffs = async () => {
  try {
    const response = await api.get(`/staffs/get/all`);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    console.error("Error fetching all active staffs:", error);
    throw new Error(handleApiError(error));
  }
};

export const deleteStaff = async (staffId) => {
  try {
    const response = await api.put(`/staff/delete`, { staffId });
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
   throw new Error(handleApiError(error));
  }
};

export const getStaffById = async (staffId) => {
  try {
    const response = await api.get(`/staff/${staffId}`);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};

export const updateStaff = async (staffId, staffData) => {
  try {
    const response = await api.put(`/staff/${staffId}`, staffData);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};
