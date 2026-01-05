import api from "../api/api";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

export default class CommonService {
  static async searchWithPagination(endpoint, keyword, page = 0, size = 8, sortBy = 'supplierName', sortDir = 'asc') {
    try {
      console.log("API Call:", { endpoint, keyword, page, size });

      const response = await api.get(endpoint, {
        params: { keyword, page, size, sortBy, sortDir }
      });
      const result = checkLogicalError(response.data);

      return result;
    } catch (error) {

   throw new Error(handleApiError(error));
    }
  }
}