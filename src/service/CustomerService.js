// src/services/CustomerService.js
import api from "../api/api";
import CommonService from './CommonService';
import { checkLogicalError, handleApiError } from "../utils/errorHandler";

class CustomerService {
  static async saveCustomer(customerData) {
    try {
      const response = await api.post("/customer/add", customerData);
      const result = checkLogicalError(response.data);
      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  static async getCustomers(page = 0, size = 8) {
    try {
      const response = await api.get("/customers/get", {
        params: { page, size },
      });
      const result = checkLogicalError(response.data);
      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  static async getAllCustomers(filter) {
    try {
      const response = await api.get("/customers/get/all",{
        params: { filter: filter },
      });
      const result = checkLogicalError(response.data);
      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  static async deleteCustomer(customerCode) {
    try {
      const response = await api.put("/customer/delete", { customerCode });
      const result = checkLogicalError(response.data);
      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Get customer by ID
  static async getCustomerById(id) {
    try {
      const response = await api.get(`/customers/get/id/${id}`);
      const result = checkLogicalError(response.data);
      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
    }
  }

  // Update customer
  static async updateCustomer(id, customerData) {
    try {
      const response = await api.put(
        `/customers/update/id/${id}`,
        customerData
      );
      const result = checkLogicalError(response.data);
      return result;
    } catch (error) {
      throw new Error(handleApiError(error));
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