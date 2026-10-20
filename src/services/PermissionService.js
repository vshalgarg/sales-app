import { checkLogicalError, handleApiError } from "../utils/errorHandler";
import api from "../api/api";

export const getAllPermission = async () => {
  try {
    const response = await api.get('/permission/all');
    return checkLogicalError(response.data);
  } catch (error) {
        throw new Error(handleApiError(error));
    }
};