import api from "../api/api";

export const getCustomers = async (page = 1, size = 8) => {
  try {
    const response = await api.get(`/customers/get`, {
      params: {
        page,
        size,
      },
    });
    return response.data;
  } catch (error) {
    throw error.response?.data || error;
  }
};

export const saveCustomer = async (customerData) => {
  try {
    const response = await api.post(`/customer/add`, customerData);
    return response.data; // Return response data
  } catch (error) {
    throw error.response?.data || error;
  }
};

export const deleteCustomer = async (customerCode) => {
  try {
    const response = await api.put(`/customer/delete`, { customerCode });
    return response.data; // Return response data
  } catch (error) {
    throw error.response?.data || error;
  }
};

export const searchCustomers = async (keyword) => {
  try {
    const response = await api.get(`/customers/search`,{ params: { keyword } });
    return response.data; // Return response data
  } catch (error) {
    throw error.response?.data || error;
  }
};
