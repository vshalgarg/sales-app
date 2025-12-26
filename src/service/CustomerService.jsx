// src/services/CustomerService.js
import api from "../api/api";
import CommonService from './CommonService';

class CustomerService {
  static async saveCustomer(customerData) {
    try {
      const response = await api.post("/customer/add", customerData);
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  }

  static async getCustomers(page = 0, size = 8) {
    try {
      const response = await api.get("/customers/get", {
        params: { page, size },
      });
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  }

  static async getAllCustomers() {
    try {
      const response = await api.get("/customers/get/all");
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  }

  static async deleteCustomer(customerCode) {
    try {
      const response = await api.put("/customer/delete", { customerCode });
      return response.data;
    } catch (error) {
      throw error.response?.data || error;
    }
  }

  static async searchCustomers(keyword, page = 0, size = 8) {
    return CommonService.searchWithPagination(
      '/customers/search',
      keyword,
      page,
      size,
      'name',
      'asc'
    );
  }
}

export default CustomerService;