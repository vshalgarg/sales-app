// src/services/SupplierService.js
import api from "../api/api";
import CommonService from "./CommonService";
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

class SupplierService {
  static async saveSupplier(supplierData) {
    try {
      const response = await api.post("/supplier/add", supplierData);
      const result = checkLogicalError(response.data);
      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  static async getSuppliers(page, size) {
    try {
      const response = await api.get("/suppliers/get", {
        params: { page, size },
      });
      const result = checkLogicalError(response.data);
      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  static async getAllSuppliers(filter) {
    try {
      const response = await api.get("/suppliers/get/all", {
        params: { filter: filter },
      });
      const result = checkLogicalError(response.data);
      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  static async deleteSupplier(code) {
    try {
      const response = await api.put("/supplier/delete", { code });
      const result = checkLogicalError(response.data);
      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  static async updateSupplier(id, supplierData) {
    try {
      const response = await api.put(
        `/suppliers/update/id/${id}`,
        supplierData,
      );

      const result = checkLogicalError(response.data);

      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  static async getSupplierById(id) {
    try {
      const response = await api.get(`/suppliers/get/id/${id}`);
      const result = checkLogicalError(response.data);
      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  static async searchSuppliers(keyword, page = 0, size = 8) {
    return CommonService.searchWithPagination(
      "/suppliers/search/v2",
      keyword,
      page,
      size,
      "supplierName",
      "asc",
    );
  }
}

export default SupplierService;
