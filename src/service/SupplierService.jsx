// src/services/SupplierService.js
import api from "../api/api";
import CommonService from './CommonService';

class SupplierService {
  static async saveSupplier(supplierData) {
    try {
      const response = await api.post("/supplier/add", supplierData);
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  }

  static async getSuppliers(page, size) {
    try {
      const response = await api.get("/suppliers/get", {
        params: { page, size },
      });
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  }

  static async getAllSuppliers() {
    try {
      const response = await api.get("/suppliers/get/all");
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  }

  static async deleteSupplier(code) {
    try {
      const response = await api.put("/supplier/delete", { code });
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  }

  static async searchSuppliers(keyword, page = 0, size = 8) {
    return CommonService.searchWithPagination(
      '/suppliers/search/v2',
      keyword,
      page,
      size,
      'supplierName',
      'asc'
    );
  }
}

export default SupplierService;