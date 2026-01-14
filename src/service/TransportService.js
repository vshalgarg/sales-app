// service/TransportService.js

import api from "../api/api";
import CommonService from './CommonService';
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

class TransportService {

  static async getTransports(page, size) {
    try {
      const response = await api.get("/transports/get/all", {
        params: { page, size },
      });
      console.log("Paginated response:", response.data);
      const result = checkLogicalError(response.data);
    return result;
    } catch (error) {
      console.error("Error fetching transports:", error);
      throw new Error(handleApiError(error));
    }
  }

  static async getAllTransports(page, size) {
    try {
      const response = await api.get("/transports/getAll")
      const result = checkLogicalError(response.data);
    return result;
    } catch (error) {
      console.error("Error fetching transports:", error);
      throw new Error(handleApiError(error));
    }
  }

  static async updateTransport(updateRequest) {
  try {
    const response = await api.put("/transports/update", updateRequest);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
}

static async createTransport(createRequest) {
  try {
    const response = await api.post("/transports/add", createRequest);
    const result = checkLogicalError(response.data);
    return result;
  } catch (error) {
    throw new Error(handleApiError(error));
  }
}

  // Delete transport
  static async deleteTransport(id) {
    try {
      const response = await api.delete(`/transports/delete/${id}`);
    const result = checkLogicalError(response.data);
    return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Search transports
  static async searchTransports(keyword, page = 0, size = 8) {
    return CommonService.searchWithPagination(
      '/transports/search',
      keyword,
      page,
      size
    );
  }

}


export default TransportService;