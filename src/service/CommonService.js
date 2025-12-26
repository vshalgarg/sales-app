import api from "../api/api";

export default class CommonService {
  static async searchWithPagination(endpoint, keyword, page = 0, size = 8, sortBy = 'supplierName', sortDir = 'asc') {
    try {
      console.log("API Call:", { endpoint, keyword, page, size });

      const response = await api.get(endpoint, {
        params: { keyword, page, size, sortBy, sortDir }
      });

    console.log("Full Response:", response);
    console.log("Response Data:", response.data);
    console.log("Response Data (stringified):", JSON.stringify(response.data, null, 2));
    console.log("Response Headers:", response.headers);
      return response.data;
    } catch (error) {

      console.error("Search Error:", error);
    console.error("Error Response:", error.response);
      throw error.response?.data || error;
    }
  }
}