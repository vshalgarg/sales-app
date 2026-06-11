import api from "../api/api";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

class AdminService {
  async changeUserPassword(payload) {
    try {
      const response = await api.put("/admin/change/password", payload);

      const result = checkLogicalError(response.data);
      return result;
    } catch (err) {
      throw new Error(handleApiError(err));
    }
  }
  async getConfigurations() {
    try {
      const response = await api.get("/admin/configurations");

      const result = checkLogicalError(response.data);
      return result;
    } catch (err) {
      throw new Error(handleApiError(err));
    }
  }
  async updateConfigurations(id, payload) {
    try {
      const response = await api.patch(`/admin/configurations/${id}`, payload);

      const result = checkLogicalError(response.data);
      return result;
    } catch (err) {
      throw new Error(handleApiError(err));
    }
  }
}

export default new AdminService();
