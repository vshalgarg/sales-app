import { checkLogicalError, handleApiError } from "../utils/errorHandler";
import api from "../api/api";

export const getAllRoles = async () => {
  try {
    const response = await api.get('/role/get/all');
    return checkLogicalError(response.data);
  } catch (error) {
        throw new Error(handleApiError(error));
    }
};

export const getRoleData = async (roleId) => {
  try {
    const response = await api.get(`/role/detail/get/${roleId}`);
    return checkLogicalError(response.data); 
  } catch(error) {
        throw new Error(handleApiError(error));
    }
};

export const createRole = async (data) => {
  try {
    const response = await api.post("/role/create",
      data 
    );
    return checkLogicalError(response.data); 
  } catch (error) {
        console.error("Error:", error.response?.data || error.message);
        throw new Error(handleApiError(error));
  }
};

export const deleteUser = async (roleId) => {
  try {
    const response = await api.delete(`/role/delete/${roleId}`);
    return checkLogicalError(response.data);
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};