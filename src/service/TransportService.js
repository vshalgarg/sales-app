// service/TransportService.js

import api from "../api/api";

class TransportService {
  // Add new transport
//   static async addTransport(transportData) {
//     try {
//       const response = await api.post("/transports/add", transportData);
//       return response.data;
//     } catch (error) {
//       console.error("Error adding transport:", error);
//       throw error.response?.data || error;
//     }
//   }

  // Get paginated transports
  static async getTransports(page, size) {
    try {
      const response = await api.get("/transports/get/all", {
        params: { page, size },
      });
      console.log("Paginated response:", response.data);
      return response.data;
    } catch (error) {
      console.error("Error fetching transports:", error);
      throw error.response?.data || error;
    }
  }

  static async updateTransport(updateRequest) {
  try {
    const response = await api.put("/transports/update", updateRequest);
    return response.data;
  } catch (error) {
    throw error;
  }
}

static async createTransport(createRequest) {
  try {
    const response = await api.post("/transports/add", createRequest);
    return response.data;
  } catch (error) {
    throw error;
  }
}

  // Delete transport
  static async deleteTransport(id) {
    try {
      const response = await api.delete(`/transports/delete/${id}`);
      return {
        success: true,
        message: response.data?.message || "Transport deleted successfully",
      };
    } catch (error) {
      console.error(`Error deleting transport ${id}:`, error);
      const msg = error.response?.data?.message || "Failed to delete transport";
      throw { success: false, message: msg };
    }
  }

  // Search transports
  static async searchTransports(query) {
    if (!query || query.trim().length < 1) {
      return [];
    }

    try {
      const response = await api.get("/transports/search", {
        params: { query: query.trim() },
      });
      console.log("Transport search response:", response.data);
      return response.data || [];
    } catch (error) {
      console.error("Transport search failed:", error);
      return [];
    }
  }
}

export default TransportService;