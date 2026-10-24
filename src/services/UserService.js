import api from "@/api/api";
import { checkLogicalError, handleApiError } from "@/utils/errorHandler";


export const createUser = async (userData) => {
    try {
        const response = await api.post("/user/add", userData);
        const result = checkLogicalError(response.data);
        return result;
    } catch (error) {
        console.error("Error creating user:", error);
        throw new Error(handleApiError(error));
    }
};

// Get all users
export const getUsers = async () => {
    try {
        const response = await api.get("/users/get");
        const result = checkLogicalError(response.data);
        return result;
    } catch (error) {
        throw new Error(handleApiError(error));
    }
};

export const deleteUser = async (userId) => {
    try {
        const response = await api.post(`/user/delete/${userId}`);
        const result = checkLogicalError(response.data);
        return result;
    } catch (error) {
        throw new Error(handleApiError(error));
    }
};

export const searchUsers = async (keyword) => {
    try {
        const response = await api.get(`/users/search`, { params: { keyword } });
        const result = checkLogicalError(response.data);
        return result;
    } catch (error) {
        throw new Error(handleApiError(error));
    }

};

export const getUserById = async (userId) => {
  try {
    const response = await api.get(`/user/roles/${userId}`);
    return checkLogicalError(response.data); 
  } catch(error) {
        throw new Error(handleApiError(error));
    }
};

export const EditUser = async (userId, payload) => {
  try {
    const response = await api.put(`/user/roles/${userId}`, payload);
    return checkLogicalError(response.data);
  } catch (error) {
    throw new Error(handleApiError(error));
  }
};
